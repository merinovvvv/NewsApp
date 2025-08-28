//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

protocol NewsRepositoryProtocol {
    
    //MARK: - News fetching
    func fetchNews(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], Error>) -> Void)
    
    //MARK: - Bookmark operations
    func saveBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void)
    func removeBookmark(article: Article, completion: @escaping (Result<Void, StorageError>) -> Void)
    func isBookmarked(article: Article, completion: @escaping (Result<Bool, StorageError>) -> Void)
    func getAllBookmarks(completion: @escaping (Result<[Article], StorageError>) -> Void)
}
