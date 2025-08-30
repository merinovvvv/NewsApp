//
//  BookmarksViewModel.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

final class BookmarksViewModel {
    
    //MARK: - Properties
    
    private let bookmarkUseCase: BookmarkUseCase
    private(set) var articles: [Article] = []
    private var allArticles: [Article] = []
    private var isSearching: Bool = false
    private var currentSearchQuery: String = ""
    
    // MARK: - Closures
    var onBookrmarksUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSelectArticle: ((Article) -> Void)?
    
    //MARK: - Init
    
    init(bookmarkUseCase: BookmarkUseCase = BookmarkUseCase()) {
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    func loadBookmarks() {
        bookmarkUseCase.getAllBookmarks { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let articles):
                self.allArticles = articles
                
                if self.isSearching {
                    self.filterArticles()
                } else {
                    self.articles = self.allArticles
                }
                
                DispatchQueue.main.async {
                    self.onBookrmarksUpdated?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func removeArticle(at index: Int, completion: @escaping (Result<Void, StorageError>) -> Void) {
        guard index < articles.count else {
            completion(.failure(.deleteFailed))
            return
        }
        
        let article = articles[index]
        bookmarkUseCase.removeFromBookmarks(article: article) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success:
                self.articles.remove(at: index)
                
                if let allIndex = self.allArticles.firstIndex(where: { $0.url == article.url }) {
                    self.allArticles.remove(at: allIndex)
                }
                
                NotificationCenter.default.post(
                    name: .bookmarkStatusChanged,
                    object: nil,
                    userInfo: ["article": article, "isBookmarked": false]
                )
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(.failure(.deleteFailed))
                }
            }
        }
    }
    
    // MARK: - Search Methods
    
    func searchBookmarks(with query: String) {
        currentSearchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentSearchQuery.isEmpty {
            isSearching = false
            articles = allArticles
        } else {
            isSearching = true
            filterArticles()
        }
        
        onBookrmarksUpdated?()
    }
    
    func cancelSearch() {
        isSearching = false
        currentSearchQuery = ""
        articles = allArticles
        onBookrmarksUpdated?()
    }
    
    // MARK: - Private Methods
    
    private func filterArticles() {
        guard !currentSearchQuery.isEmpty else {
            articles = allArticles
            return
        }
        
        let query = currentSearchQuery.lowercased()
        articles = allArticles.filter { article in
            article.title.lowercased().contains(query) ||
            article.description?.lowercased().contains(query) == true ||
            article.author?.lowercased().contains(query) == true ||
            article.sourceName.lowercased().contains(query)
        }
    }
}
