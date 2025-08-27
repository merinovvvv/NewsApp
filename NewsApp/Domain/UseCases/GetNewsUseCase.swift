//
//  GetNewsUseCase.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class GetNewsUseCase {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        repository.fetchNews(category: category, page: page, completion: completion)
    }
}
