//
//  MainTabBarController.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    
    //MARK: - UI Properties
    
    private var newsVC: NewsListViewController
    private var bookmarksVC: BookmarksViewController
    
    private let newsNav: UINavigationController
    private let bookmarksNav: UINavigationController
    
    //MARK: - Init
    
    init() {
        let repository = NewsRepositoryImpl(apiService: NetworkService(), storage: CoreDataNewsStorage.shared)
        let newsViewModel = NewsListViewModel(repository: repository)
        self.newsVC = NewsListViewController(viewModel: newsViewModel)
        self.bookmarksVC = BookmarksViewController()
        
        self.newsNav = UINavigationController(rootViewController: newsVC)
        self.bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repository = NewsRepositoryImpl(apiService: NetworkService(), storage: CoreDataNewsStorage.shared)
        let newsViewModel = NewsListViewModel(repository: repository)
        newsVC = NewsListViewController(viewModel: newsViewModel)
        
        bookmarksVC = BookmarksViewController()
        
        
        setupViewControllers()
    }
    
    //MARK: - Private
    
    private func setupViewControllers() {
        newsVC.title = "News"
        newsNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
        
        bookmarksVC.title = "Bookmarks"
        bookmarksNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        
        viewControllers = [newsNav, bookmarksNav]
    }
}
