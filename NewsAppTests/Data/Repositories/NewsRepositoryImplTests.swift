//
//  NewsRepositoryImplTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - News Repository Tests
final class NewsRepositoryImplTests: XCTestCase {
    var sut: NewsRepositoryImpl!
    var mockNetworkService: MockNetworkService!
    var mockCacheManager: MockNewsCacheManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockCacheManager = MockNewsCacheManager()
        sut = NewsRepositoryImpl(apiService: mockNetworkService, cacheManager: mockCacheManager)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
    func testFetchNewsSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch news success")
        let testResponse = TestDataFactory.createTestResponseData()
        mockNetworkService.responseToReturn = testResponse
        mockNetworkService.shouldReturnError = false
        mockCacheManager.shouldReturnCachedData = false
        
        // When
        sut.fetchNews(category: .general, page: 1) { result in
            // Then
            switch result {
            case .success(let articles):
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles.first?.title, "Test Article")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchNewsNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch news network error")
        mockNetworkService.shouldReturnError = true
        mockNetworkService.errorToReturn = .noInternetConnection
        
        // When
        sut.fetchNews(category: .general, page: 1) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

