import UIKit
import CoreData

final class NewsCacheManager {
    
    // MARK: - Properties
    
    static let shared = NewsCacheManager()
    
    private let cacheLifetime: TimeInterval = 30 * 60
    private let maxCachedPages = 5
    
    private var safeContext: NSManagedObjectContext {
        if Thread.isMainThread {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.persistentContainer.viewContext
        } else {
            let appDelegate = DispatchQueue.main.sync {
                UIApplication.shared.delegate as! AppDelegate
            }
            let backgroundContext = appDelegate.persistentContainer.newBackgroundContext()
            return backgroundContext
        }
    }
    
    private init() { }
    
    // MARK: - Public Methods
    
    func cacheArticles(_ articles: [Article], category: NewsCategory, page: Int) {
        let context = safeContext
        
        context.perform {
            self.clearCache(for: category, page: page, in: context)
            
            let now = Date()
            let expiresAt = now.addingTimeInterval(self.cacheLifetime)
            
            for (index, article) in articles.enumerated() {
                guard let entity = NSEntityDescription.entity(forEntityName: "CachedArticle", in: context) else { continue }
                
                let cachedArticle = CachedArticle(entity: entity, insertInto: context)
                
                cachedArticle.title = article.title
                cachedArticle.articleDescription = article.description
                cachedArticle.content = article.content
                cachedArticle.author = article.author
                cachedArticle.url = article.url
                cachedArticle.urlToImage = article.urlToImage
                cachedArticle.publishedAt = article.publishedAt
                cachedArticle.sourceName = article.sourceName
                
                cachedArticle.category = category.rawValue
                cachedArticle.page = Int32(page)
                cachedArticle.cachedAt = now
                cachedArticle.expiresAt = expiresAt
                cachedArticle.position = Int32(index)
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to save cached articles: \(error)")
            }
            
            self.cleanupOldPages(for: category, in: context)
        }
    }
    
    func getCachedArticles(category: NewsCategory, page: Int, completion: @escaping (([Article], Bool)?) -> Void) {
        let context = safeContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "category == %@ AND page == %d",
                category.rawValue,
                page
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
            
            do {
                let cachedArticles = try context.fetch(fetchRequest)
                
                guard !cachedArticles.isEmpty else {
                    completion(nil)
                    return
                }
                
                let now = Date()
                let isExpired = cachedArticles.first?.expiresAt?.compare(now) == .orderedAscending
                
                let articles = cachedArticles.map { cached in
                    Article(
                        title: cached.title ?? "",
                        description: cached.articleDescription,
                        content: cached.content,
                        author: cached.author,
                        url: cached.url ?? "",
                        urlToImage: cached.urlToImage,
                        publishedAt: cached.publishedAt ?? Date(),
                        sourceName: cached.sourceName ?? ""
                    )
                }
                
                completion((articles, isExpired))
                
            } catch {
                print("Failed to fetch cached articles: \(error)")
                completion(nil)
            }
        }
    }
    
    func hasCachedData(category: NewsCategory, page: Int, completion: @escaping (Bool) -> Void) {
        let context = safeContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "category == %@ AND page == %d",
                category.rawValue,
                page
            )
            fetchRequest.fetchLimit = 1
            
            do {
                let count = try context.count(for: fetchRequest)
                completion(count > 0)
            } catch {
                completion(false)
            }
        }
    }
    
    func clearAllCache() {
        let context = safeContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
            
            do {
                let cachedArticles = try context.fetch(fetchRequest)
                for article in cachedArticles {
                    context.delete(article)
                }
                try context.save()
            } catch {
                print("Failed to clear cache: \(error)")
            }
        }
    }
    
    func clearCache(for category: NewsCategory) {
        let context = safeContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
            
            do {
                let cachedArticles = try context.fetch(fetchRequest)
                for article in cachedArticles {
                    context.delete(article)
                }
                try context.save()
            } catch {
                print("Failed to clear category cache: \(error)")
            }
        }
    }
    
    func removeExpiredCache() {
        let context = safeContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "expiresAt < %@", Date() as NSDate)
            
            do {
                let cachedArticles = try context.fetch(fetchRequest)
                for article in cachedArticles {
                    context.delete(article)
                }
                try context.save()
            } catch {
                print("Failed to remove expired cache: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func clearCache(for category: NewsCategory, page: Int, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "category == %@ AND page == %d",
            category.rawValue,
            page
        )
        
        do {
            let cachedArticles = try context.fetch(fetchRequest)
            for article in cachedArticles {
                context.delete(article)
            }
        } catch {
            print("Failed to clear page cache: \(error)")
        }
    }
    
    private func cleanupOldPages(for category: NewsCategory, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]
        
        do {
            let allArticles = try context.fetch(fetchRequest)
            
            let groupedByPage = Dictionary(grouping: allArticles) { $0.page }
            let sortedPages = groupedByPage.keys.sorted { page1, page2 in
                
                let articles1 = groupedByPage[page1] ?? []
                let articles2 = groupedByPage[page2] ?? []
                
                let maxDate1 = articles1.compactMap { $0.cachedAt }.max() ?? Date.distantPast
                let maxDate2 = articles2.compactMap { $0.cachedAt }.max() ?? Date.distantPast
                
                return maxDate1 > maxDate2
            }
            
            if sortedPages.count > maxCachedPages {
                let pagesToDelete = Array(sortedPages.dropFirst(maxCachedPages))
                
                for page in pagesToDelete {
                    if let articlesToDelete = groupedByPage[page] {
                        for article in articlesToDelete {
                            context.delete(article)
                        }
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save after cleanup: \(error)")
                }
            }
        } catch {
            print("Failed to cleanup old pages: \(error)")
        }
    }
}
