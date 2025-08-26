//
//  GetNewsUseCase.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class GetNewsUseCase {
    private let repository: NewsRepository

    init(repository: NewsRepository) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<[Article], Error>) -> Void) {
        repository.fetchNews(completion: completion)
    }
}
