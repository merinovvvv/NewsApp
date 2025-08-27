//
//  GetBookmarksUseCase.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class GetBookmarksUseCase {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<[Article], Error>) -> Void) {
        repository.getBookmarks(completion: completion)
    }
}
