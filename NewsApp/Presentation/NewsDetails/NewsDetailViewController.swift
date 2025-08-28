//
//  NewsDetailsViewController.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit

final class NewsDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: NewsDetailViewModel
    
    //MARK: - Constants
    
    private enum Constants {
        
        //MARK: - Constraints
        
        static let scrollViewContentInset: CGFloat = 16
        static let imageHeight: CGFloat = 300
        static let verticalSpacing: CGFloat = 16
        static let smallVerticalSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 25
        
        //MARK: - Values
        
        static let titleFontSize: CGFloat = 24
        static let contentFontSize: CGFloat = 16
        static let authorFontSize: CGFloat = 14
        static let dateFontSize: CGFloat = 14
        static let imageButtonPadding: CGFloat = 16
        
    }
    
    //MARK: - UI Properties
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    
    private let articleImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let sourceLabel: UILabel = UILabel()
    private let contentLabel: UILabel = UILabel()
    private let bookmarkButton: UIButton = UIButton(type: .system)
    private var config = UIButton.Configuration.plain()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBindings()
        setupUI()
        
        viewModel.loadArticle()
    }
    
    //MARK: - Init
    
    init(viewModel: NewsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    
    private func setupBindings() {
        viewModel.onArticleUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.onBookmarkStatusChanged = { [weak self] isBookmarked in
            DispatchQueue.main.async {
                self?.updateBookmarkButton(isBookmarked: isBookmarked)
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showError(error)
            }
        }
    }
    
    private func updateUI() {
        titleLabel.text = viewModel.title
        authorLabel.text = viewModel.author
        dateLabel.text = viewModel.publishedDate
        sourceLabel.text = viewModel.sourceName
        contentLabel.text = viewModel.content
        
        articleImageView.image = viewModel.placeholderImage()
        
        if let imageURL = viewModel.imageURL {
            ImageCacheManager.shared.loadImage(from: imageURL) { [weak self] image in
                guard let self else { return }
                self.articleImageView.image = image ?? self.viewModel.placeholderImage()
            }
        }
        
        updateBookmarkButton(isBookmarked: viewModel.isBookmarked)
    }
    
    //TODO: - Make animation better
    
    private func updateBookmarkButton(isBookmarked: Bool) {
        let title = isBookmarked ? "Remove from Bookmarks" : "Add to Bookmarks"
        let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
        let backgroundColor: UIColor = isBookmarked ? .systemRed : .systemBlue
        
        var newConfig = config
        newConfig.title = title
        newConfig.image = UIImage(systemName: imageName)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        newConfig.imagePadding = Constants.imageButtonPadding
        newConfig.baseForegroundColor = .white
        
        bookmarkButton.configurationUpdateHandler = { button in
            let updatedConfig = button.configuration
            if button.isHighlighted {
                button.backgroundColor = backgroundColor.withAlphaComponent(0.5)
            } else {
                button.backgroundColor = backgroundColor
            }
            button.configuration = updatedConfig
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bookmarkButton.configuration = newConfig
            self.bookmarkButton.backgroundColor = backgroundColor
        })
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
}

//MARK: - Setup UI
private extension NewsDetailViewController {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(articleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(bookmarkButton)
    }
    
    func setupConstraints() {
        [scrollView, contentView, articleImageView, titleLabel, authorLabel, dateLabel, sourceLabel, contentLabel, bookmarkButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.scrollViewContentInset),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.scrollViewContentInset),
            articleImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            
            titleLabel.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: Constants.verticalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.scrollViewContentInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.scrollViewContentInset),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallVerticalSpacing),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: Constants.smallVerticalSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            sourceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.smallVerticalSpacing),
            sourceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sourceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: Constants.verticalSpacing),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            bookmarkButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: Constants.verticalSpacing * 2),
            bookmarkButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bookmarkButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            bookmarkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalSpacing)
        ])
    }
    
    
    func configureViews() {
        
        configureNavigationItem()
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        articleImageView.contentMode = .scaleAspectFit
        articleImageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        authorLabel.font = .systemFont(ofSize: Constants.authorFontSize, weight: .medium)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: Constants.dateFontSize, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        
        sourceLabel.font = .systemFont(ofSize: Constants.dateFontSize, weight: .medium)
        sourceLabel.textColor = .systemBlue
        
        contentLabel.font = .systemFont(ofSize: Constants.contentFontSize, weight: .regular)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        
        bookmarkButton.titleLabel?.font = .systemFont(ofSize: Constants.contentFontSize, weight: .semibold)
        bookmarkButton.setTitleColor(.white, for: .normal)
        bookmarkButton.layer.cornerRadius = Constants.buttonCornerRadius
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        
    }
    
    func configureNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonTapped)
        )
    }
}

//MARK: - Selectors

private extension NewsDetailViewController {
    @objc private func bookmarkButtonTapped() {
        viewModel.toggleBookmark()
    }
    
    @objc private func shareButtonTapped() {
        guard let url = viewModel.articleURL else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true)
    }
}
