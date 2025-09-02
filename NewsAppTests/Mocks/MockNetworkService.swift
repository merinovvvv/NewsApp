//
//  MockNetworkService.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

@testable import NewsApp

// MARK: - Mock Network Service
final class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var errorToReturn: NetworkError = .noData
    var responseToReturn: ResponseData?
    
    func request<T: Decodable>(_ endpoint: NewsEndpoint, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        if shouldReturnError {
            completion(.failure(errorToReturn))
            return
        }
        
        if let response = responseToReturn as? T {
            completion(.success(response))
        } else {
            completion(.failure(.decodingError))
        }
    }
}
