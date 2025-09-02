//
//  MockBookmarksRepository.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

@testable import NewsApp

// MARK: - Mock Bookmarks Repository
final class MockBookmarksRepository: BookmarksRepositoryProtocol {
    private let mockStorage = MockCoreDataNewsStorage()
    var shouldReturnError = false
    var errorToReturn: StorageError = .saveFailed
    
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        mockStorage.shouldReturnError = shouldReturnError
        mockStorage.errorToReturn = errorToReturn
        mockStorage.saveBookmark(article: article, completion: completion)
    }
    
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        mockStorage.shouldReturnError = shouldReturnError
        mockStorage.errorToReturn = errorToReturn
        mockStorage.removeBookmark(article: article, completion: completion)
    }
    
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        mockStorage.shouldReturnError = shouldReturnError
        mockStorage.errorToReturn = errorToReturn
        mockStorage.isBookmarked(article: article, completion: completion)
    }
    
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void) {
        mockStorage.shouldReturnError = shouldReturnError
        mockStorage.errorToReturn = errorToReturn
        mockStorage.getAllBookmarks(completion: completion)
    }
}
