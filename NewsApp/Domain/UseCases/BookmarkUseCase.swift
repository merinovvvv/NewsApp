//
//  BookmarkUseCase.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 28.08.25.
//

import Foundation

final class BookmarkUseCase {
    
    private let repository: NewsRepositoryProtocol
    
    init(repository: NewsRepositoryProtocol = NewsRepositoryImpl()) {
        self.repository = repository
    }
    
    func addToBookmarks(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        repository.saveBookmark(article: article, completion: completion)
    }
    
    func removeFromBookmarks(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        repository.removeBookmark(article: article, completion: completion)
    }
    
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        repository.isBookmarked(article: article, completion: completion)
    }
    
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void) {
        repository.getAllBookmarks(completion: completion)
    }
}
