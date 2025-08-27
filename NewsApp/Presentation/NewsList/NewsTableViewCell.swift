//
//  NewsCell.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit

import UIKit

final class NewsTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let identifier: String = "NewsCell"
    
    private var viewModel: NewsCellViewModel!
    
    //MARK: - Constants
    
    private enum Constants {
        
        //MARK: - Constraints
        
        static let imageWidthAnchor: CGFloat = 100
        static let imageHeightAnchor: CGFloat = 80
        
        static let hStackVerticalSpacing: CGFloat = 12
        static let hStackHorizontalSpacing: CGFloat = 16
        
        //MARK: - Values
        
        static let hStackContentSpacing: CGFloat = 24
        
        static let vStackContentSpacing: CGFloat = 8
        
        static let titleLabelFontSize: CGFloat = 17
        
        static let infoStackContentSpacing: CGFloat = 4
        
        static let infoStackLabelsFontSize: CGFloat = 13
        
        
    }
    
    //MARK: - UI Properties
    
    private let hStack: UIStackView = UIStackView()
    
    private let newsImageView: UIImageView = UIImageView()
    
    private let vStack: UIStackView = UIStackView()
    private let titleLabel: UILabel = UILabel()
    
    private let infoStack: UIStackView = UIStackView()
    private let sourceNameLabel: UILabel = UILabel()
    private let publishedDateLabel: UILabel = UILabel()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        titleLabel.text = nil
        sourceNameLabel.text = nil
        publishedDateLabel.text = nil
    }
    
    func configure(with viewModel: NewsCellViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        sourceNameLabel.text = viewModel.sourceName
        publishedDateLabel.text = viewModel.publishedDateText
        
        newsImageView.image = viewModel.placeholderImage()
        
        if let url = viewModel.imageURL {
            ImageCacheManager.shared.loadImage(from: url) { [weak self] image in
                guard let self else { return }
                self.newsImageView.image = image ?? viewModel.placeholderImage()
            }
        }
    }
}

//MARK: - Setup UI
private extension NewsTableViewCell {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        contentView.addSubview(hStack)
        
        hStack.addArrangedSubview(newsImageView)
        hStack.addArrangedSubview(vStack)
        
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(infoStack)
        
        infoStack.addArrangedSubview(sourceNameLabel)
        infoStack.addArrangedSubview(publishedDateLabel)
    }
    
    func setupConstraints() {
        [hStack, newsImageView, vStack, titleLabel, infoStack, sourceNameLabel, publishedDateLabel].forEach( { $0.translatesAutoresizingMaskIntoConstraints = false })
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.hStackVerticalSpacing),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hStackHorizontalSpacing),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hStackHorizontalSpacing),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.hStackVerticalSpacing),
            
            newsImageView.widthAnchor.constraint(equalToConstant: Constants.imageWidthAnchor),
            newsImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeightAnchor)
        ])
    }
    
    func configureViews() {
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .center
        hStack.spacing = Constants.hStackContentSpacing
        
        newsImageView.contentMode = .scaleAspectFit
        
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.alignment = .leading
        vStack.spacing = Constants.vStackContentSpacing
        
        titleLabel.numberOfLines = .zero
        titleLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize, weight: .medium)
        titleLabel.textColor = .label
        
        infoStack.axis = .horizontal
        infoStack.alignment = .center
        infoStack.spacing = Constants.infoStackContentSpacing
        
        sourceNameLabel.font = .systemFont(ofSize: Constants.infoStackLabelsFontSize, weight: .regular)
        sourceNameLabel.textColor = .secondaryLabel
        
        publishedDateLabel.textColor = .secondaryLabel
        publishedDateLabel.font = .systemFont(ofSize: Constants.infoStackLabelsFontSize, weight: .regular)
    }
}
