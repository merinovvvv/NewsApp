//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

protocol NewsRepositoryProtocol {
    
    //MARK: - News fetching
    func fetchNews(category: NewsCategory, page: Int, completion: @escaping (Result<[Article], Error>) -> Void)
}
