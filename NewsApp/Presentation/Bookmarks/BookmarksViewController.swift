//
//  BookmarksViewController.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

//TODO: - Simultaneous delete in News and Bookmarks error

import UIKit

final class BookmarksViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: BookmarksViewModel
    private var currentSearchQuery: String = ""
    
    //MARK: - Constants
    
    private enum Constants {
        
        static let tableViewEstimatedHeightForRow: CGFloat = 120
        
        static let noBookmarksLabelFontSize: CGFloat = 17
        
    }
    
    //MARK: - UI Properties
    
    private let tableView: UITableView = UITableView()
    private let noBookmarksLabel: UILabel = UILabel()
    private let searchController = UISearchController()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupBindings()
        
        viewModel.loadBookmarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewModel.loadBookmarks()
        }
    
    //MARK: - Init
    
    init(viewModel: BookmarksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    
    func setupBindings() {
        viewModel.onBookrmarksUpdated = { [weak self] in
            
            guard let self else { return }
            
            if self.viewModel.articles.count == 0 {
                self.updateNoBookmarksMessage()
                self.noBookmarksLabel.isHidden = false
            } else {
                self.noBookmarksLabel.isHidden = true
            }
            
            self.tableView.reloadData()
        }
        
        //TODO: - Same logic as in NewsListViewController
        
        viewModel.onError = { [weak self] errorMessage in
            guard self?.presentedViewController == nil else { return }
            
            let alert = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onSelectArticle = { [weak self] article in
            
            guard let self else { return }
            
            let vc = NewsDetailViewController(viewModel: NewsDetailViewModel(article: article), bookmarksViewModel: self.viewModel)
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func updateNoBookmarksMessage() {
        if searchController.isActive && !currentSearchQuery.isEmpty {
            noBookmarksLabel.text = "No bookmarks found for '\(currentSearchQuery)'"
        } else {
            noBookmarksLabel.text = "Your bookmarks will appear here"
        }
    }
}

//MARK: - Setup UI
private extension BookmarksViewController {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(noBookmarksLabel)
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        noBookmarksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            noBookmarksLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noBookmarksLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configureViews() {
        
        configureSearchController()
        
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        
        noBookmarksLabel.isHidden = true
        noBookmarksLabel.text = "Your bookmarks will appear here"
        noBookmarksLabel.font = .systemFont(ofSize: Constants.noBookmarksLabelFontSize, weight: .medium)
        noBookmarksLabel.textColor = .secondaryLabel
        noBookmarksLabel.textAlignment = .center
        noBookmarksLabel.numberOfLines = .zero
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search bookmarks"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension BookmarksViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeArticle(at: indexPath.row) { [weak self] result in
                
                guard let self else { return }
                
                switch result {
                case .success:
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    if self.viewModel.articles.count == 0 {
                        self.noBookmarksLabel.isHidden = false
                    } else {
                        self.noBookmarksLabel.isHidden = true
                    }
                    
                case .failure(let error):
                    self.viewModel.onError?(error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate

extension BookmarksViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.3)
        
        currentSearchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentSearchQuery = ""
        viewModel.cancelSearch()
    }
    
    @objc private func performSearch() {
        viewModel.searchBookmarks(with: currentSearchQuery)
    }
}
