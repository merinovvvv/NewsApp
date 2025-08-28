//
//  CoreDataNewsStorage.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit
import CoreData

final class CoreDataNewsStorage {
    
    static let shared: CoreDataNewsStorage = CoreDataNewsStorage()
    
    private init() { }
    
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Save Bookmark
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        
        guard let bookmarkEntityDescription = NSEntityDescription.entity(forEntityName: "BookmarkArticle", in: context) else { return }
        
        let fetchRequest: NSFetchRequest<BookmarkArticle> = BookmarkArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let existing = try context.fetch(fetchRequest)
            if !existing.isEmpty {
                completion(.failure(.alreadyExists))
                return
            }
            
            let entity = BookmarkArticle(entity: bookmarkEntityDescription, insertInto: context)
            entity.url = article.url
            entity.title = article.title
            entity.author = article.author
            entity.content = article.content
            entity.articleDescription = article.description
            entity.urlToImage = article.urlToImage
            entity.publishedAt = article.publishedAt
            entity.sourceName = article.sourceName
            
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.saveFailed))
        }
    }
    
    // MARK: - Remove Bookmark
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        let fetchRequest: NSFetchRequest<BookmarkArticle> = BookmarkArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let existing = try context.fetch(fetchRequest)
            guard let objectToDelete = existing.first else {
                completion(.failure(.deleteFailed))
                return
            }
            context.delete(objectToDelete)
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.deleteFailed))
        }
    }
    
    // MARK: - Check if Bookmarked
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        let fetchRequest: NSFetchRequest<BookmarkArticle> = BookmarkArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let count = try context.count(for: fetchRequest)
            completion(.success(count > 0))
        } catch {
            completion(.failure(.fetchFailed))
        }
    }
    
    // MARK: - Fetch All Bookmarks
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void) {
        let fetchRequest: NSFetchRequest<BookmarkArticle> = BookmarkArticle.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let articles = results.map { entity in
                Article(
                    title: entity.title ?? "",
                    description: entity.author,
                    content: entity.articleDescription,
                    author: entity.content,
                    url: entity.url ?? "",
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt ?? Date(),
                    sourceName: entity.sourceName ?? ""
                )
            }
            completion(.success(articles))
        } catch {
            completion(.failure(.fetchFailed))
        }
    }
}
