//
//  ToggleBookmarkUseCase.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class ToggleBookmarkUseCase {
    private let repository: NewsRepository
    
    init(repository: NewsRepository) {
        self.repository = repository
    }
    
    func execute(article: Article, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.toggleBookmark(article: article, completion: completion)
    }
}
