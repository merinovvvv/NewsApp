//
//  DTO.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

// MARK: - ResponseData
struct ResponseData: Decodable {
    let status: String
    let totalResults: Int
    let articles: [ArticleDTO]
}

// MARK: - Article
struct ArticleDTO: Decodable {
    let source: SourceDTO
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?
}

// MARK: - Source
struct SourceDTO: Decodable {
    let id: String?
    let name: String
}

extension ArticleDTO {
    func toDomain() -> Article {
        Article(
            title: title,
            description: description ?? "",
            content: content ?? "",
            author: author ?? "",
            url: url,
            urlToImage: urlToImage ?? "",
            publishedAt: publishedAt,
            sourceName: source.name
        )
    }
}
