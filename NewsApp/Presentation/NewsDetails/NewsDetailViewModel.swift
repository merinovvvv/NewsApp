//
//  NewsDetailsViewModel.swift.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

//
//  NewsDetailViewModel.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 28.08.25.
//

import Foundation
import UIKit

final class NewsDetailViewModel {
    
    // MARK: - Properties
    
    private let article: Article
    private let bookmarkUseCase: BookmarkUseCase
    private(set) var isBookmarked: Bool = false
    
    // MARK: - Closures
    
    var onArticleUpdated: (() -> Void)?
    var onBookmarkStatusChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Computed Properties
    
    var title: String {
        article.title
    }
    
    var author: String {
        if let author = article.author, !author.isEmpty {
            return "By \(author)"
        }
        return "Unknown Author"
    }
    
    var publishedDate: String {
        return article.publishedAt.detailedDateDisplay()
    }
    
    var sourceName: String {
        return "Source: \(article.sourceName)"
    }
    
    var content: String {
        if let content = article.content, !content.isEmpty {
            return content
        } else if let description = article.description, !description.isEmpty {
            return description
        }
        return "Full content is not available. Please visit the source website for complete article."
    }
    
    var imageURL: URL? {
        guard let urlString = article.urlToImage else { return nil }
        return URL(string: urlString)
    }
    
    var articleURL: URL? {
        return URL(string: article.url)
    }
    
    // MARK: - Init
    
    init(article: Article, bookmarkUseCase: BookmarkUseCase = BookmarkUseCase()) {
        self.article = article
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    // MARK: - Public Methods
    
    func loadArticle() {
        checkBookmarkStatus()
        onArticleUpdated?()
    }
    
    func toggleBookmark() {
        if isBookmarked {
            removeFromBookmarks()
        } else {
            addToBookmarks()
        }
    }
    
    func placeholderImage() -> UIImage {
        return UIImage(systemName: "photo") ?? UIImage()
    }
    
    // MARK: - Private Methods
    
    private func checkBookmarkStatus() {
        bookmarkUseCase.isBookmarked(article: article) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isBookmarked):
                    self?.isBookmarked = isBookmarked
                    self?.onBookmarkStatusChanged?(isBookmarked)
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    private func addToBookmarks() {
        bookmarkUseCase.addToBookmarks(article: article) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isBookmarked = true
                    self?.onBookmarkStatusChanged?(true)
                case .failure(let error):
                    self?.onError?("Failed to add bookmark: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func removeFromBookmarks() {
        bookmarkUseCase.removeFromBookmarks(article: article) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isBookmarked = false
                    self?.onBookmarkStatusChanged?(false)
                case .failure(let error):
                    self?.onError?("Failed to remove bookmark: \(error.localizedDescription)")
                }
            }
        }
    }
}
