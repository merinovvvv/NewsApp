//
//  ThemeManager.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import UIKit

enum Theme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    private let themeKey = "selectedTheme"
    
    private init() {}
    
    var currentTheme: Theme {
        get {
            let savedTheme = UserDefaults.standard.integer(forKey: themeKey)
            return Theme(rawValue: savedTheme) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    func saveTheme(_ theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    func loadSavedTheme() {
        let theme = currentTheme
        applyTheme(theme)
    }
    
    private func applyTheme(_ theme: Theme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
    
    func setupInitialTheme() {
        loadSavedTheme()
    }
}
