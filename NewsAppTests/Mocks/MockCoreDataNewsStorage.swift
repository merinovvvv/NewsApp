//
//  MockCoreDataNewsStorage.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

@testable import NewsApp

// MARK: - Mock Core Data Storage
final class MockCoreDataNewsStorage {
    private var bookmarkedArticles: [Article] = []
    var shouldReturnError = false
    var errorToReturn: StorageError = .saveFailed
    
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        if shouldReturnError {
            completion(.failure(errorToReturn))
            return
        }
        
        if bookmarkedArticles.contains(where: { $0.url == article.url }) {
            completion(.failure(.alreadyExists))
            return
        }
        
        bookmarkedArticles.append(article)
        completion(.success(()))
    }
    
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        if shouldReturnError {
            completion(.failure(errorToReturn))
            return
        }
        
        if let index = bookmarkedArticles.firstIndex(where: { $0.url == article.url }) {
            bookmarkedArticles.remove(at: index)
            completion(.success(()))
        } else {
            completion(.failure(.deleteFailed))
        }
    }
    
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        if shouldReturnError {
            completion(.failure(errorToReturn))
            return
        }
        
        let isBookmarked = bookmarkedArticles.contains(where: { $0.url == article.url })
        completion(.success(isBookmarked))
    }
    
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void) {
        if shouldReturnError {
            completion(.failure(errorToReturn))
            return
        }
        
        completion(.success(bookmarkedArticles))
    }
}
