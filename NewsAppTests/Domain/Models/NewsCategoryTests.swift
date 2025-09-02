//
//  NewsCategoryTests.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 2.09.25.
//

import XCTest
@testable import NewsApp

final class NewsCategoryTests: XCTestCase {
    
    func testNewsCategoryDisplayNames() {
        XCTAssertEqual(NewsCategory.general.displayName, "General")
        XCTAssertEqual(NewsCategory.business.displayName, "Business")
        XCTAssertEqual(NewsCategory.entertainment.displayName, "Entertainment")
        XCTAssertEqual(NewsCategory.health.displayName, "Health")
        XCTAssertEqual(NewsCategory.science.displayName, "Science")
        XCTAssertEqual(NewsCategory.sports.displayName, "Sports")
        XCTAssertEqual(NewsCategory.technology.displayName, "Technology")
    }
    
    func testNewsCategoryRawValues() {
        XCTAssertEqual(NewsCategory.general.rawValue, "general")
        XCTAssertEqual(NewsCategory.business.rawValue, "business")
        XCTAssertEqual(NewsCategory.entertainment.rawValue, "entertainment")
        XCTAssertEqual(NewsCategory.health.rawValue, "health")
        XCTAssertEqual(NewsCategory.science.rawValue, "science")
        XCTAssertEqual(NewsCategory.sports.rawValue, "sports")
        XCTAssertEqual(NewsCategory.technology.rawValue, "technology")
    }
    
    func testNewsCategoryAllCases() {
        let allCases = NewsCategory.allCases
        XCTAssertEqual(allCases.count, 7)
        XCTAssertTrue(allCases.contains(.general))
        XCTAssertTrue(allCases.contains(.business))
        XCTAssertTrue(allCases.contains(.entertainment))
        XCTAssertTrue(allCases.contains(.health))
        XCTAssertTrue(allCases.contains(.science))
        XCTAssertTrue(allCases.contains(.sports))
        XCTAssertTrue(allCases.contains(.technology))
    }
}
