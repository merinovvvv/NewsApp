//
//  ViewController.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit

final class NewsListViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: NewsListViewModel
    private let bookmarksViewModel: BookmarksViewModel
    private var selectedCategoryIndex = Constants.zero
    private var currentSearchQuery: String = ""
    
    //MARK: - Constants
    
    private enum Constants {
        
        //MARK: - Constraints
        
        static let categoryHeaderHeight: CGFloat = 50
        
        //MARK: - Values
        
        static let zero: Int = 0
        
        static let activityIndicatorTag: Int = 999
        
        static let tableViewEstimatedHeightForRow: CGFloat = 120
        
        static let interitemSpacing: CGFloat = 8
        static let lineSpacing: CGFloat = 8
        
        static let verticalEdgeSpacing: CGFloat = 8
        static let horizontalEdgeSpacing: CGFloat = 16
        
        static let scrollBottomSpacing: CGFloat = 50
        
        static let collectionViewCellTextFont: CGFloat = 14
        static let collectionViewCellTextPadding: CGFloat = 20
        static let collectionViewCellHeight: CGFloat = 32
        static let minCollectionViewCellTextWidth: CGFloat = 70
    }
    
    //MARK: - UI Properties
    
    private let tableView: UITableView = UITableView()
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    private let searchController = UISearchController()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing
        
        layout.sectionInset = UIEdgeInsets(top: Constants.verticalEdgeSpacing, left: Constants.horizontalEdgeSpacing, bottom: Constants.verticalEdgeSpacing, right: Constants.horizontalEdgeSpacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    //MARK: - Init
    
    init(viewModel: NewsListViewModel, bookmarksViewModel: BookmarksViewModel) {
        self.viewModel = viewModel
        self.bookmarksViewModel = bookmarksViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupBindings()
        setupUI()
        
        let initialCategory = NewsCategory.allCases[selectedCategoryIndex]
        viewModel.selectCategory(initialCategory)
        
        viewModel.loadInitialNews()
    }
    
    //MARK: - Private Methods
    
    private func setupBindings() {
        viewModel.onArticlesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if self?.refreshControl.isRefreshing == false {
                    self?.showLoading(isLoading)
                }
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showError(error)
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.onSelectArticle = { [weak self] article in
            
            guard let self else { return }
            
            let vc = NewsDetailViewController(viewModel: NewsDetailViewModel(article: article), bookmarksViewModel: self.bookmarksViewModel)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.tag = Constants.activityIndicatorTag
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            view.viewWithTag(Constants.activityIndicatorTag)?.removeFromSuperview()
        }
    }
    
    private func showError(_ message: String) {
        
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func selectCategory(at index: Int) {
        let previousIndex = selectedCategoryIndex
        selectedCategoryIndex = index
        
        var indexPathsToReload: [IndexPath] = []
        if previousIndex < NewsCategory.allCases.count {
            indexPathsToReload.append(IndexPath(item: previousIndex, section: .zero))
        }
        indexPathsToReload.append(IndexPath(item: selectedCategoryIndex, section: .zero))
        
        categoryCollectionView.reloadItems(at: indexPathsToReload)
        
        categoryCollectionView.scrollToItem(
            at: IndexPath(item: selectedCategoryIndex, section: .zero),
            at: .centeredHorizontally,
            animated: true
        )
        
        clearSearchController()
        
        let category = NewsCategory.allCases[selectedCategoryIndex]
        viewModel.selectCategory(category)
    }
    
    private func clearSearchController() {
        
        if searchController.isActive {
            searchController.searchBar.text = ""
            currentSearchQuery = ""
        }
    }
}

//MARK: - Setup UI
private extension NewsListViewController {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(categoryCollectionView)
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: Constants.categoryHeaderHeight),
            
            
            tableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    func configureViews() {
        
        configureSearchController()
        
        tableView.refreshControl = refreshControl
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        categoryCollectionView.backgroundColor = .systemBackground
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshNews)
        )
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search articles"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < viewModel.articles.count else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.articles[indexPath.row]
        let viewModel = NewsCellViewModel(article: article)
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.articles[indexPath.row]
        viewModel.onSelectArticle?(article)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewEstimatedHeightForRow
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - Constants.scrollBottomSpacing {
            viewModel.loadMoreNewsIfNeeded()
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension NewsListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NewsCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = NewsCategory.allCases[indexPath.item]
        let isSelected = indexPath.item == selectedCategoryIndex
        cell.configure(with: category, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedCategoryIndex else { return }
        selectCategory(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = NewsCategory.allCases[indexPath.item]
        let font = UIFont.systemFont(ofSize: Constants.collectionViewCellTextFont, weight: .medium)
        let textWidth = category.displayName.size(withAttributes: [.font: font]).width
        let cellWidth = textWidth + Constants.collectionViewCellTextPadding
        let cellHeight: CGFloat = Constants.collectionViewCellHeight
        
        return CGSize(width: max(cellWidth, Constants.minCollectionViewCellTextWidth), height: cellHeight)
    }
}

//MARK: - UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate

extension NewsListViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.3)
        
        currentSearchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.cancelSearch()
    }
    
    @objc private func performSearch() {
        viewModel.searchArticles(with: currentSearchQuery)
    }
}

//MARK: - Selectors

private extension NewsListViewController {
    @objc func refreshNews() {
        
        clearSearchController()
        viewModel.refreshNews()
    }
}
