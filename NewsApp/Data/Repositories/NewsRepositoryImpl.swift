//
//  NewsRepositoryImpl.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

final class NewsRepositoryImpl: NewsRepositoryProtocol {
    
    private let apiService: NetworkServiceProtocol
    private let storage: CoreDataNewsStorage
    
    init(apiService: NetworkServiceProtocol = NetworkService(), storage: CoreDataNewsStorage = .shared) {
        self.apiService = apiService
        self.storage = storage
    }
    
    // MARK: - News Fetching
    
    func fetchNews(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], any Error>) -> Void) {
        let endpoint = NewsEndpoint.topHeadlines(
            category: category,
            page: page,
            country: APIConfiguration.defaultCountry
        )
        
        apiService.request(endpoint, type: ResponseData.self) { result in
            switch result {
            case .success(let response):
                let articles = response.articles.map { $0.toDomain() }
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
