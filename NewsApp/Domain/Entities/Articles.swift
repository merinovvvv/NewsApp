//
//  Articles.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

// MARK: - Article
struct Article: Decodable {
    let title: String
    let description: String?
    let content: String?
    let author: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let sourceName: String
}
