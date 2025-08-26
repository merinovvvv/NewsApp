//
//  NewsCategory.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

// MARK: - NewsCategory
enum NewsCategory: String, CaseIterable {
    case general
    case business
    case entertainment
    case health
    case science
    case sports
    case technology
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .business: return "Business"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .science: return "Science"
        case .sports: return "Sports"
        case .technology: return "Technology"
        }
    }
}
