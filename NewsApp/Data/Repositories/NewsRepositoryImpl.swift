//
//  NewsRepositoryImpl.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

final class NewsRepositoryImpl {
    private let apiService: NetworkService
    private let storage: CoreDataNewsStorage
    
    init(apiService: NetworkService, storage: CoreDataNewsStorage) {
        self.apiService = apiService
        self.storage = storage
    }
}
