//
//  NewsListViewModel.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import Foundation

final class NewsListViewModel {
    
    // MARK: - Properties
    
    private let getNewsUseCase: GetNewsUseCase
    private let cacheManager: NewsCacheManager
    
    private(set) var articles: [Article] = []
    private var allArticles: [Article] = []
    private var isSearching: Bool = false
    private var currentSearchQuery: String = ""
    
    private var currentCategory: NewsCategory = .general
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    
    private var lastLoadTime: Date = .distantPast
    private let minLoadInterval: TimeInterval = 2.0
    private var hasMorePages = true
    
    private(set) var cacheState: CacheState = .fresh
    
    // MARK: - Closures
    var onArticlesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onCacheStateChanged: ((CacheState, String?) -> Void)?
    var onSelectArticle: ((Article) -> Void)?
    
    // MARK: - Init
    init(getNewsUseCase: GetNewsUseCase = GetNewsUseCase(),
         cacheManager: NewsCacheManager = .shared) {
        self.getNewsUseCase = getNewsUseCase
        self.cacheManager = cacheManager
        
        cacheManager.removeExpiredCache()
    }
    
    // MARK: - Public Methods
    
    func loadInitialNews() {
        currentPage = 1
        articles.removeAll()
        allArticles.removeAll()
        hasMorePages = true
        fetchNews(category: currentCategory, page: currentPage, isRefreshing: true)
    }
    
    func selectCategory(_ category: NewsCategory) {
        currentPage = 1
        hasMorePages = true
        lastLoadTime = .distantPast
        
        guard category != currentCategory else { return }
        currentCategory = category
        
        isSearching = false
        currentSearchQuery = ""
        
        loadInitialNews()
    }
    
    func loadMoreNewsIfNeeded() {
        guard !isSearching else { return }
        
        let now = Date()
        guard now.timeIntervalSince(lastLoadTime) >= minLoadInterval else {
            return
        }
        
        lastLoadTime = now
        
        guard !isLoading else { return }
        
        guard hasMorePages else { return }
        
        currentPage += 1
        fetchNews(category: currentCategory, page: currentPage, isRefreshing: false)
    }
    
    func refreshNews() {
        isSearching = false
        currentSearchQuery = ""
        
        cacheManager.clearCache(for: currentCategory)
        loadInitialNews()
    }
    
    func clearCache() {
        cacheManager.clearAllCache()
        onCacheStateChanged?(.fresh, "Cache cleared successfully")
    }
    
    // MARK: - Search Methods
    
    func searchArticles(with query: String) {
        currentSearchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentSearchQuery.isEmpty {
            isSearching = false
            articles = allArticles
        } else {
            isSearching = true
            filterArticles()
        }
        
        onArticlesUpdated?()
    }
    
    func cancelSearch() {
        isSearching = false
        currentSearchQuery = ""
        articles = allArticles
        onArticlesUpdated?()
    }
    
    // MARK: - Private Methods
    
    private func fetchNews(category: NewsCategory, page: Int, isRefreshing: Bool) {
        isLoading = true
        onLoadingStateChanged?(true)
        
        cacheManager.hasCachedData(category: category, page: page) { [weak self] hasCachedData in
            guard let self else { return }
            
            self.getNewsUseCase.execute(category: category, page: page) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onLoadingStateChanged?(false)
                    
                    switch result {
                    case .success(let newArticles):
                        if isRefreshing {
                            self.allArticles = newArticles
                        } else {
                            self.allArticles.append(contentsOf: newArticles)
                        }
                        
                        if self.isSearching {
                            self.filterArticles()
                        } else {
                            self.articles = self.allArticles
                        }
                        
                        self.cacheState = .fresh
                        self.onCacheStateChanged?(.fresh, nil)
                        
                        self.onArticlesUpdated?()
                        
                        if newArticles.isEmpty {
                            self.hasMorePages = false
                        }
                        
                    case .failure(let error):
                        if let networkError = error as? NetworkError,
                           networkError == .noInternetConnection {
                            
                            if hasCachedData {
                                self.cacheState = .expired
                                self.onCacheStateChanged?(.expired, "Showing cached data. No internet connection.")
                                
                                if !self.articles.isEmpty {
                                    self.onArticlesUpdated?()
                                }
                            } else {
                                self.cacheState = .error
                                self.onCacheStateChanged?(.error, "No internet connection and no cached data available")
                                self.onError?("No internet connection. Please check your network.")
                            }
                            
                        } else {
                            self.cacheState = .error
                            self.onError?(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func filterArticles() {
        guard !currentSearchQuery.isEmpty else {
            articles = allArticles
            return
        }
        
        let query = currentSearchQuery.lowercased()
        articles = allArticles.filter { article in
            article.title.lowercased().contains(query) ||
            article.description?.lowercased().contains(query) == true ||
            article.author?.lowercased().contains(query) == true ||
            article.sourceName.lowercased().contains(query)
        }
    }
}
