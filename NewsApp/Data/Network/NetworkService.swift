//
//  NewsAPIService.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

// MARK: - Network Configuration
enum APIConfiguration {
    static let scheme = "https"
    static let host = "newsapi.org"
    static let basePath = "/v2"
    static let apiKey = "a3ad2bcbab7a41eea6da776b5da4db2a"
    static let defaultCountry = "us"
    static let pageSize = 20
}

enum NewsEndpoint {
    case topHeadlines(category: NewsCategory, page: Int, country: String)
    case everything(query: String, page: Int)
    
    private var path: String {
        switch self {
        case .topHeadlines:
            return "\(APIConfiguration.basePath)/top-headlines"
        case .everything:
            return "\(APIConfiguration.basePath)/everything"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: APIConfiguration.apiKey),
            URLQueryItem(name: "pageSize", value: String(APIConfiguration.pageSize))
        ]
        
        switch self {
        case .topHeadlines(let category, let page, let country):
            items.append(URLQueryItem(name: "country", value: country))
            if category != .general {
                items.append(URLQueryItem(name: "category", value: category.rawValue))
            }
            items.append(URLQueryItem(name: "page", value: String(page)))
            
        case .everything(let query, let page):
            items.append(URLQueryItem(name: "q", value: query))
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "sortBy", value: "popularity"))
        }
        
        return items
    }
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIConfiguration.scheme
        urlComponents.host = APIConfiguration.host
        urlComponents.path = self.path
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: NewsEndpoint, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
}

//MARK: - Network Service Implementation

final class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: NewsEndpoint,type: T.Type,completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard !APIConfiguration.apiKey.isEmpty else {
            completion(.failure(.apiKeyMissing))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                if let error = error as? URLError {
                    switch error.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        completion(.failure(.noInternetConnection))
                    default:
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                completion(.failure(.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let responseData = try decoder.decode(T.self, from: data)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodingError))
                }
            case 401:
                completion(.failure(.apiKeyMissing))
                return
            case 429:
                completion(.failure(.rateLimitExceeded))
                return
            default:
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
        }.resume()
    }
}
