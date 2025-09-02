//
//  BookmarksRepositoryImpl.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 29.08.25.
//

import Foundation

final class BookmarksRepositoryImpl: BookmarksRepositoryProtocol {
    
    private let storage: NewsStorageProtocol
    
    init(storage: NewsStorageProtocol = CoreDataNewsStorage.shared) {
        self.storage = storage
    }
    
    // MARK: - Bookmark Operations
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        storage.saveBookmark(article: article) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void) {
        storage.removeBookmark(article: article) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        storage.isBookmarked(article: article) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void) {
        storage.getAllBookmarks { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
