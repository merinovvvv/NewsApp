//
//  NewsRepositoryImpl.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class NewsRepositoryImpl: NewsRepositoryProtocol {
    
    private let apiService: NetworkServiceProtocol
    private let storage: CoreDataNewsStorage
    
    init(apiService: NetworkServiceProtocol, storage: CoreDataNewsStorage) {
        self.apiService = apiService
        self.storage = storage
    }
    
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
    
    func toggleBookmark(article: Article, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func getBookmarks(completion: @escaping (Result<[Article], any Error>) -> Void) {
        
    }
}
