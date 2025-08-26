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
    private var selectedCategoryIndex = 0
    
    //MARK: - Constants
    
    private enum Constants {
        
        //MARK: - Constraints
        
        static let categoryHeaderHeight: CGFloat = 50
        
        //MARK: - Values
        
        static let interitemSpacing: CGFloat = 8
        static let lineSpacing: CGFloat = 8
        
        static let verticalEdgeSpacing: CGFloat = 8
        static let HorizontalEdgeSpacing: CGFloat = 16
        
    }
    
    //MARK: - UI Properties
    
    private let tableView: UITableView = UITableView()
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing
        
        layout.sectionInset = UIEdgeInsets(top: Constants.verticalEdgeSpacing, left: Constants.HorizontalEdgeSpacing, bottom: Constants.verticalEdgeSpacing, right: Constants.HorizontalEdgeSpacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    //MARK: - Init
    
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //setupBindings()
        setupUI()
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
        tableView.refreshControl = refreshControl
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        categoryCollectionView.backgroundColor = .systemBackground
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        categoryCollectionView.layer.shadowColor = UIColor.black.cgColor
        categoryCollectionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        categoryCollectionView.layer.shadowRadius = 2
        categoryCollectionView.layer.shadowOpacity = 0.1
        
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshNews)
        )
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .red
        return cell
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension NewsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.backgroundColor = .blue
        return cell
    }
}

//MARK: - Selectors

private extension NewsListViewController {
    @objc func refreshNews() {
        
    }
}
