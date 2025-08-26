//
//  BookmarkArticle+CoreDataProperties.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//
//

import Foundation
import CoreData

@objc(BookmarkArticle)
public class BookmarkArticle: NSManagedObject { }


extension BookmarkArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkArticle> {
        return NSFetchRequest<BookmarkArticle>(entityName: "BookmarkArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var content: String?
    @NSManaged public var author: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var sourceName: String?

}

extension BookmarkArticle : Identifiable { }
