//
//  ArticleTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - ArticleTests Domain Model Tests
final class ArticleTests: XCTestCase {
    
    func testArticleCreation() {
        // Given
        let title = "Test Title"
        let description = "Test Description"
        let url = "https://test.com"
        let publishedAt = Date()
        let sourceName = "Test Source"
        
        // When
        let article = Article(
            title: title,
            description: description,
            content: nil,
            author: nil,
            url: url,
            urlToImage: nil,
            publishedAt: publishedAt,
            sourceName: sourceName
        )
        
        // Then
        XCTAssertEqual(article.title, title)
        XCTAssertEqual(article.description, description)
        XCTAssertEqual(article.url, url)
        XCTAssertEqual(article.publishedAt, publishedAt)
        XCTAssertEqual(article.sourceName, sourceName)
        XCTAssertNil(article.content)
        XCTAssertNil(article.author)
    }
}
