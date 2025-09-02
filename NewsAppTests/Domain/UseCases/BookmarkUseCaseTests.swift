//
//  BookmarkUseCaseTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - BookmarkUseCase Tests

final class BookmarkUseCaseTests: XCTestCase {
    var sut: BookmarkUseCase!
    var mockRepository: MockBookmarksRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockBookmarksRepository()
        sut = BookmarkUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testAddToBookmarksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Add to bookmarks success")
        let testArticle = TestDataFactory.createTestArticle()
        mockRepository.shouldReturnError = false
        
        // When
        sut.addToBookmarks(article: testArticle) { result in
            // Then
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddToBookmarksFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Add to bookmarks failure")
        let testArticle = TestDataFactory.createTestArticle()
        mockRepository.shouldReturnError = true
        mockRepository.errorToReturn = .saveFailed
        
        // When
        sut.addToBookmarks(article: testArticle) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .saveFailed)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveFromBookmarksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Remove from bookmarks success")
        let testArticle = TestDataFactory.createTestArticle()
        
        // First add bookmark
        sut.addToBookmarks(article: testArticle) { _ in }
        
        // When
        sut.removeFromBookmarks(article: testArticle) { result in
            // Then
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testIsBookmarkedAfterAdding() {
        // Given
        let expectation = XCTestExpectation(description: "Is bookmarked after adding")
        let testArticle = TestDataFactory.createTestArticle()
        
        // First add bookmark
        sut.addToBookmarks(article: testArticle) { _ in }
        
        // When
        sut.isBookmarked(article: testArticle) { result in
            // Then
            switch result {
            case .success(let isBookmarked):
                XCTAssertTrue(isBookmarked)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetAllBookmarksEmpty() {
        // Given
        let expectation = XCTestExpectation(description: "Get all bookmarks empty")
        
        // When
        sut.getAllBookmarks { result in
            // Then
            switch result {
            case .success(let articles):
                XCTAssertEqual(articles.count, 0)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
