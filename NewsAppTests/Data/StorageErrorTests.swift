//
//  StorageErrorTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - Storage Error Tests
final class StorageErrorTests: XCTestCase {
    
    func testStorageErrorDescriptions() {
        XCTAssertEqual(StorageError.saveFailed.errorDescription, "Failed to save data to storage")
        XCTAssertEqual(StorageError.fetchFailed.errorDescription, "Failed to fetch data from storage")
        XCTAssertEqual(StorageError.updateFailed.errorDescription, "Failed to update data in storage")
        XCTAssertEqual(StorageError.deleteFailed.errorDescription, "Failed to delete data from storage")
        XCTAssertEqual(StorageError.alreadyExists.errorDescription, "Data already exists.")
    }
}
