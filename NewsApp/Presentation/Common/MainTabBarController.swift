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
    
    private var themeSwitchButton: UIButton = UIButton(type: .system)
    
    //MARK: - Constants
    
    private enum Constants {
        
        //MARK: - Constraints
        
        static let themeSwitchButtonSizeAnchor: CGFloat = 50
        
        //MARK: - Values
        
        static let themeSwitchButtonCornerRadius: CGFloat = 25
        static let themeSwitchButtonShadowRadius: CGFloat = 4
        static let themeSwitchButtonShadowOpacity: Float = 0.2
        static let themeSwitchButtonShadowOffset: CGSize = .init(width: .zero, height: -2)
        
    }
    
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
        setupUI()
        updateThemeButtonAppearance()
        
        setupTraitObservation()
    }
    
    //MARK: - Private
    
    private func setupViewControllers() {
        newsVC.title = "News"
        newsNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
        
        bookmarksVC.title = "Bookmarks"
        bookmarksNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        
        viewControllers = [newsNav, bookmarksNav]
    }
    
    private func toggleTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let isDark = (window.overrideUserInterfaceStyle == .dark) ||
                     (window.overrideUserInterfaceStyle == .unspecified && traitCollection.userInterfaceStyle == .dark)
        
        let newStyle: UIUserInterfaceStyle = isDark ? .light : .dark
        window.overrideUserInterfaceStyle = newStyle
        ThemeManager.shared.saveTheme(newStyle == .dark ? .dark : .light)
    }

    
    private func updateThemeButtonAppearance() {
        let currentStyle = view.window?.overrideUserInterfaceStyle ?? traitCollection.userInterfaceStyle
        let iconName = currentStyle == .dark ? "sun.max.fill" : "moon.fill"
        let iconColor: UIColor = currentStyle == .dark ? .systemYellow : .systemBlue
        
        themeSwitchButton.setImage(UIImage(systemName: iconName), for: .normal)
        themeSwitchButton.tintColor = iconColor
    }
    
    private func setupTraitObservation() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.updateThemeButtonAppearance()
        }
    }
}


//MARK: - Setup ui

private extension MainTabBarController {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        view.addSubview(themeSwitchButton)
    }
    
    func setupConstraints() {
        themeSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            themeSwitchButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            themeSwitchButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            themeSwitchButton.widthAnchor.constraint(equalToConstant: Constants.themeSwitchButtonSizeAnchor),
            themeSwitchButton.heightAnchor.constraint(equalToConstant: Constants.themeSwitchButtonSizeAnchor)
        ])
    }
    
    func configureViews() {
        themeSwitchButton.setImage(UIImage(systemName: "moon.fill"), for: .normal)
        themeSwitchButton.backgroundColor = UIColor.systemBackground
        themeSwitchButton.layer.cornerRadius = Constants.themeSwitchButtonCornerRadius
        themeSwitchButton.layer.shadowColor = UIColor.black.cgColor
        themeSwitchButton.layer.shadowOffset = Constants.themeSwitchButtonShadowOffset
        themeSwitchButton.layer.shadowRadius = Constants.themeSwitchButtonShadowRadius
        themeSwitchButton.layer.shadowOpacity = Constants.themeSwitchButtonShadowOpacity
        
        themeSwitchButton.addTarget(self, action: #selector(themeSwitchButtonTapped), for: .touchUpInside)
    }
}

//MARK: - Selectors

private extension MainTabBarController {
    @objc private func themeSwitchButtonTapped() {
        if let window = view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                self.toggleTheme()
            }
        }
        
        updateThemeButtonAppearance()
    }
}
