//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

protocol NewsRepository {
    func fetchNews(completion: @escaping (Result<[Article], Error>) -> Void)
    func toggleBookmark(article: Article, completion: @escaping (Result<Void, Error>) -> Void)
    func getBookmarks(completion: @escaping (Result<[Article], Error>) -> Void)
}
