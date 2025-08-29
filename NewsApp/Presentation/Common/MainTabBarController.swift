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
        let newsViewModel = NewsListViewModel()
        let bookmarksViewModel = BookmarksViewModel()
        newsVC = NewsListViewController(viewModel: newsViewModel, bookmarksViewModel: bookmarksViewModel)
        bookmarksVC = BookmarksViewController(viewModel: bookmarksViewModel)
        
        newsNav = UINavigationController(rootViewController: newsVC)
        bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
