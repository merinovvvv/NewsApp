//
//  GetNewsUseCaseTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - GetNewsUseCase Tests
final class GetNewsUseCaseTests: XCTestCase {
    var sut: GetNewsUseCase!
    var mockRepository: NewsRepositoryImpl!
    var mockNetworkService: MockNetworkService!
    var mockCacheManager: MockNewsCacheManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockCacheManager = MockNewsCacheManager()
        mockRepository = NewsRepositoryImpl(apiService: mockNetworkService,
                                            cacheManager: mockCacheManager)
        sut = GetNewsUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testExecuteSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Execute success")
        let testResponse = TestDataFactory.createTestResponseData()
        mockNetworkService.responseToReturn = testResponse
        mockNetworkService.shouldReturnError = false
        
        // When
        sut.execute(category: .general, page: 1) { result in
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
    
    func testExecuteFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Execute failure")
        mockNetworkService.shouldReturnError = true
        mockNetworkService.errorToReturn = .noInternetConnection
        
        // When
        sut.execute(category: .general, page: 1) { result in
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
