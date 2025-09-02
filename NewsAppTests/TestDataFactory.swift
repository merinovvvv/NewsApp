//
//  TestDataFactory.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - Test Data Factory
final class TestDataFactory {
    static func createTestArticle() -> Article {
        return Article(
            title: "Test Article",
            description: "Test Description",
            content: "Test Content",
            author: "Test Author",
            url: "https://test.com/article",
            urlToImage: "https://test.com/image.jpg",
            publishedAt: Date(),
            sourceName: "Test Source"
        )
    }
    
    static func createTestArticleDTO() -> ArticleDTO {
        let source = SourceDTO(id: "test-source", name: "Test Source")
        return ArticleDTO(
            source: source,
            author: "Test Author",
            title: "Test Article",
            description: "Test Description",
            url: "https://test.com/article",
            urlToImage: "https://test.com/image.jpg",
            publishedAt: Date(),
            content: "Test Content"
        )
    }
    
    static func createTestResponseData() -> ResponseData {
        return ResponseData(
            status: "ok",
            totalResults: 1,
            articles: [createTestArticleDTO()]
        )
    }
}
