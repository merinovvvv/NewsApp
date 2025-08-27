//
//  NewsAPIService.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case serverError(Int)
    case apiKeyMissing
    case rateLimitExceeded
    case unknown(Error)
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .apiKeyMissing:
            return "API key is missing"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
}

// MARK: - Network Configuration
enum APIConfiguration {
    static let scheme = "https"
    static let host = "newsapi.org/v2"
    static let apiKey = "a3ad2bcbab7a41eea6da776b5da4db2a"
    static let defaultCountry = "us"
    static let pageSize = 20
}

enum NewsEndpoint {
    case topHeadlines(category: NewsCategory, page: Int, country: String)
    case everything(query: String, page: Int)
    
    var path: String {
        switch self {
        case .topHeadlines:
            return "/top-headlines"
        case .everything:
            return "/everything"
        }
    }
    
    var queryItems: [URLQueryItem] {
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
        
        guard APIConfiguration.apiKey != "a3ad2bcbab7a41eea6da776b5da4db2a" else {
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
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let responseData = try JSONDecoder().decode(T.self, from: data)
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
           
        }
    }
}

