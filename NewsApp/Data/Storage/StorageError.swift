//
//  StorageError.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 28.08.25.
//

import Foundation

// MARK: - Storage Error
enum StorageError: LocalizedError {
    case saveFailed
    case fetchFailed
    case updateFailed
    case deleteFailed
    case alreadyExists
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data to storage"
        case .fetchFailed:
            return "Failed to fetch data from storage"
        case .updateFailed:
            return "Failed to update data in storage"
        case .deleteFailed:
            return "Failed to delete data from storage"
        case .alreadyExists:
            return "Data already exists."
        }
    }
}
