//
//  DTOTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

// MARK: - DTO Tests
final class DTOTests: XCTestCase {
    
    func testArticleDTOToDomainMapping() {
        // Given
        let articleDTO = TestDataFactory.createTestArticleDTO()
        
        // When
        let domainArticle = articleDTO.toDomain()
        
        // Then
        XCTAssertEqual(domainArticle.title, articleDTO.title)
        XCTAssertEqual(domainArticle.description, articleDTO.description)
        XCTAssertEqual(domainArticle.author, articleDTO.author)
        XCTAssertEqual(domainArticle.url, articleDTO.url)
        XCTAssertEqual(domainArticle.sourceName, articleDTO.source.name)
    }
    
    func testArticleDTOToDomainMappingWithNilValues() {
        // Given
        let source = SourceDTO(id: nil, name: "Test Source")
        let articleDTO = ArticleDTO(
            source: source,
            author: nil,
            title: "Test Title",
            description: nil,
            url: "https://test.com",
            urlToImage: nil,
            publishedAt: Date(),
            content: nil
        )
        
        // When
        let domainArticle = articleDTO.toDomain()
        
        // Then
        XCTAssertEqual(domainArticle.title, "Test Title")
        XCTAssertEqual(domainArticle.description, "")
        XCTAssertEqual(domainArticle.author, "")
        XCTAssertEqual(domainArticle.urlToImage, "")
    }
}

