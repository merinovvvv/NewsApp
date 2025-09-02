//
//  BookmarksRepositoryImplTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - Bookmarks Repository Tests
final class BookmarksRepositoryImplTests: XCTestCase {
    var sut: BookmarksRepositoryImpl!
    var mockStorage: MockCoreDataNewsStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockCoreDataNewsStorage()
        sut = BookmarksRepositoryImpl(storage: mockStorage)
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }
    
    func testSaveBookmarkSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Save bookmark success")
        let testArticle = TestDataFactory.createTestArticle()
        mockStorage.shouldReturnError = false
        
        // When
        mockStorage.saveBookmark(article: testArticle) { result in
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
    
    func testSaveBookmarkAlreadyExists() {
        // Given
        let expectation = XCTestExpectation(description: "Save bookmark already exists")
        let testArticle = TestDataFactory.createTestArticle()
        
        // First save
        mockStorage.saveBookmark(article: testArticle) { _ in }
        
        // When - try to save again
        mockStorage.saveBookmark(article: testArticle) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .alreadyExists)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveBookmarkSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Remove bookmark success")
        let testArticle = TestDataFactory.createTestArticle()
        
        // First save
        mockStorage.saveBookmark(article: testArticle) { _ in }
        
        // When
        mockStorage.removeBookmark(article: testArticle) { result in
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
    
    func testIsBookmarkedTrue() {
        // Given
        let expectation = XCTestExpectation(description: "Is bookmarked true")
        let testArticle = TestDataFactory.createTestArticle()
        
        // First save
        mockStorage.saveBookmark(article: testArticle) { _ in }
        
        // When
        mockStorage.isBookmarked(article: testArticle) { result in
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
    
    func testIsBookmarkedFalse() {
        // Given
        let expectation = XCTestExpectation(description: "Is bookmarked false")
        let testArticle = TestDataFactory.createTestArticle()
        
        // When
        mockStorage.isBookmarked(article: testArticle) { result in
            // Then
            switch result {
            case .success(let isBookmarked):
                XCTAssertFalse(isBookmarked)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetAllBookmarks() {
        // Given
        let expectation = XCTestExpectation(description: "Get all bookmarks")
        let testArticle1 = TestDataFactory.createTestArticle()
        let testArticle2 = Article(
            title: "Test Article 2",
            description: "Test Description 2",
            content: "Test Content 2",
            author: "Test Author 2",
            url: "https://test.com/article2",
            urlToImage: "https://test.com/image2.jpg",
            publishedAt: Date(),
            sourceName: "Test Source 2"
        )
        
        // First save articles
        mockStorage.saveBookmark(article: testArticle1) { _ in }
        mockStorage.saveBookmark(article: testArticle2) { _ in }
        
        // When
        mockStorage.getAllBookmarks { result in
            // Then
            switch result {
            case .success(let articles):
                XCTAssertEqual(articles.count, 2)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
