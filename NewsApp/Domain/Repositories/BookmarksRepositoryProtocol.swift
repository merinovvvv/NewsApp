//
//  BookmarksRepositoryProtocol.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 29.08.25.
//

protocol BookmarksRepositoryProtocol {
    
    //MARK: - Bookmark operations
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void)
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void)
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void)
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void)
}
