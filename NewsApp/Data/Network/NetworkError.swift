//
//  NetworkError.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 28.08.25.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError, Equatable {
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
    
    // MARK: - Equatable
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.apiKeyMissing, .apiKeyMissing),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.noInternetConnection, .noInternetConnection):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.unknown(lhsError), .unknown(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
