//
//  NewsRepositoryImpl.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

final class NewsRepositoryImpl: NewsRepositoryProtocol {
    
    // MARK: - Properties
    
    private let apiService: NetworkServiceProtocol
    private let cacheManager: NewsCacheManagerProtocol
    
    // MARK: - Init
    
    init(apiService: NetworkServiceProtocol = NetworkService(),
         cacheManager: NewsCacheManagerProtocol = NewsCacheManager.shared) {
        self.apiService = apiService
        self.cacheManager = cacheManager
    }
    
    // MARK: - News Fetching
    
    func fetchNews(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        
        cacheManager.getCachedArticles(category: category, page: page) { [weak self] cachedResult in
            
            if let cachedData = cachedResult {
                let (articles, isExpired) = cachedData
                
                if !isExpired {
                    completion(.success(articles))
                    return
                }
                
                self?.fetchFromNetwork(category: category, page: page) { [weak self] result in
                    switch result {
                    case .success(let networkArticles):
                        self?.cacheManager.cacheArticles(networkArticles, category: category, page: page)
                        completion(.success(networkArticles))
                        
                    case .failure(let error):
                        if case NetworkError.noInternetConnection = error {
                            print("Returning expired cache due to no internet connection")
                            completion(.success(articles))
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
                
            } else {
                self?.fetchFromNetwork(category: category, page: page) { [weak self] result in
                    switch result {
                    case .success(let articles):
                        self?.cacheManager.cacheArticles(articles, category: category, page: page)
                        completion(.success(articles))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchFromNetwork(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
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
}
