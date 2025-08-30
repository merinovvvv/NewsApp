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
    
    // MARK: - Closures
    var onArticlesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    var onSelectArticle: ((Article) -> Void)?
    
    // MARK: - Init
    init(getNewsUseCase: GetNewsUseCase = GetNewsUseCase()) {
        self.getNewsUseCase = getNewsUseCase
    }
    
    // MARK: - Public Methods
    
    func loadInitialNews() {
        currentPage = 1
        articles.removeAll()
        allArticles.removeAll()
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
        loadInitialNews()
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
        
        getNewsUseCase.execute(category: category, page: page) { [weak self] result in
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
                    
                    self.onArticlesUpdated?()
                    
                    if newArticles.isEmpty {
                        self.hasMorePages = false
                    }
                    
                case .failure(let error):
                    self.onError?(error.localizedDescription)
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
