//
//  BookmarksViewModel.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

final class BookmarksViewModel {
    
    //MARK: - Properties
    
    private let bookmarkUseCase: BookmarkUseCase
    private(set) var articles: [Article] = []
    
    // MARK: - Closures
    var onBookrmarksUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSelectArticle: ((Article) -> Void)?
    
    //MARK: - Init
    
    init(bookmarkUseCase: BookmarkUseCase = BookmarkUseCase()) {
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    func loadBookmarks() {
        bookmarkUseCase.getAllBookmarks { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let articles):
                self.articles = articles
                
                DispatchQueue.main.async {
                    self.onBookrmarksUpdated?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
