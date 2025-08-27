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
    //TODO: - select article
    var onSelectArticle: ((Article) -> Void)?
    
    // MARK: - Init
    init(getNewsUseCase: GetNewsUseCase) {
        self.getNewsUseCase = getNewsUseCase
    }
    
    // MARK: - Public Methods
    
    func loadInitialNews() {
        currentPage = 1
        articles.removeAll()
        fetchNews(category: currentCategory, page: currentPage, isRefreshing: true)
    }
    
    func selectCategory(_ category: NewsCategory) {
        currentPage = 1
        hasMorePages = true
        lastLoadTime = .distantPast
        
        guard category != currentCategory else { return }
        currentCategory = category
        loadInitialNews()
    }
    
    func loadMoreNewsIfNeeded() {
        
        let now = Date()
        guard now.timeIntervalSince(lastLoadTime) >= minLoadInterval else {
            return  // Exit early if not enough time has passed
        }
        
        lastLoadTime = now
        
        guard !isLoading else { return }
        
        guard hasMorePages else { return }
        
        currentPage += 1
        fetchNews(category: currentCategory, page: currentPage, isRefreshing: false)
    }
    
    func refreshNews() {
        loadInitialNews()
    }
//    
//    func toggleBookmark(for article: Article) {
//        repository.toggleBookmark(article: article) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.fetchBookmarks()
//                case .failure(let error):
//                    self?.onError?(error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    func fetchBookmarks() {
//        repository.getBookmarks { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let bookmarks):
//                    self?.articles = bookmarks
//                    self?.onArticlesUpdated?()
//                case .failure(let error):
//                    self?.onError?(error.localizedDescription)
//                }
//            }
//        }
//    }
    
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
                        self.articles = newArticles
                    } else {
                        self.articles.append(contentsOf: newArticles)
                    }
                    self.onArticlesUpdated?()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
