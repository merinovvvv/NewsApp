//
//  CategoryCollectionViewCell.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let identifier: String = "CategoryCollectionViewCell"
    
    //MARK: - UI Properties
    
    private let titleLabel: UILabel = UILabel()
    
    //MARK: - Constants
    
    private enum Constants {
        static let contentViewCornerRadius: CGFloat = 12
        
        static let collectionViewCellTextFont: CGFloat = 14
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    
    override func prepareForReuse() {
        transform = .identity
        titleLabel.text = nil
    }
    
    func configure(with category: NewsCategory, isSelected: Bool) {
        titleLabel.text = category.displayName
        
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.contentView.backgroundColor = .systemBlue
                self.titleLabel.textColor = .white
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                self.contentView.backgroundColor = .systemGray5
                self.titleLabel.textColor = .label
                self.transform = .identity
            }
        }
    }
}

//MARK: - Setup UI
private extension CategoryCollectionViewCell {
    func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureViews() {
        
        self.contentView.layer.cornerRadius = Constants.contentViewCornerRadius
        self.contentView.clipsToBounds = true
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: Constants.collectionViewCellTextFont, weight: .medium)
    }
}
