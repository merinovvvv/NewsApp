//
//  NetworkServiceTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - Network Service Tests
final class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    
    override func setUp() {
        super.setUp()
        sut = NetworkService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNetworkErrorEquality() {
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.serverError(404), NetworkError.serverError(404))
        XCTAssertNotEqual(NetworkError.serverError(404), NetworkError.serverError(500))
    }
    
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.serverError(404).errorDescription, "Server error: 404")
        XCTAssertEqual(NetworkError.apiKeyMissing.errorDescription, "API key is missing")
    }
}

