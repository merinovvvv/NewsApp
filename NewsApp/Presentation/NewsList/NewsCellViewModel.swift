//
//  NewsCellViewModel.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation
import UIKit

final class NewsCellViewModel {

    // MARK: - Properties
    private let article: Article
    
    var title: String {
        article.title
    }
    
    var description: String {
        article.description ?? ""
    }
    
    var sourceName: String {
        article.sourceName
    }
    
    var publishedDateText: String {
        article.publishedAt.timeAgoDisplay()
    }
    
    var imageURL: URL? {
        guard let urlString = article.urlToImage else { return nil }
        return URL(string: urlString)
    }
    
    // MARK: - Init
    init(article: Article) {
        self.article = article
    }
    
    // MARK: - Optional Helpers
    func placeholderImage() -> UIImage {
        UIImage(systemName: "photo") ?? UIImage()
    }
}
