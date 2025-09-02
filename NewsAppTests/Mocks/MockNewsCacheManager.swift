//
//  MockNewsCacheManager.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

@testable import NewsApp

// MARK: - Mock Cache Manager
final class MockNewsCacheManager: NewsCacheManagerProtocol {
    
    var shouldReturnCachedData = false
    var cachedDataToReturn: ([Article], Bool)?
    var hasCachedDataResult = false
    private(set) var cachedArticles: [Article] = []
    private(set) var cacheCategory: NewsCategory?
    private(set) var cachePage: Int?
    
    func getCachedArticles(category: NewsCategory, page: Int, completion: @escaping (([Article], Bool)?) -> Void) {
        if shouldReturnCachedData {
            completion(cachedDataToReturn)
        } else {
            completion(nil)
        }
    }
    
    func cacheArticles(_ articles: [Article], category: NewsCategory, page: Int) {
        cachedArticles = articles
        cacheCategory = category
        cachePage = page
    }
    
    func hasCachedData(category: NewsCategory, page: Int, completion: @escaping (Bool) -> Void) {
        completion(hasCachedDataResult)
    }
    
    func clearAllCache() {
        cachedArticles = []
    }
    
    func clearCache(for category: NewsApp.NewsCategory) {
        if cacheCategory == category {
            cachedArticles = []
            cacheCategory = nil
            cachePage = nil
        }
    }
    
    func removeExpiredCache() { }
}
