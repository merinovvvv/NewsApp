//
//  CachedArticle+CoreDataProperties.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 31.08.25.
//
//

import Foundation
import CoreData

@objc(CachedArticle)
public class CachedArticle: NSManagedObject { }

extension CachedArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedArticle> {
        return NSFetchRequest<CachedArticle>(entityName: "CachedArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var content: String?
    @NSManaged public var author: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var sourceName: String?
    @NSManaged public var category: String?
    @NSManaged public var page: Int32
    @NSManaged public var cachedAt: Date?
    @NSManaged public var expiresAt: Date?
    @NSManaged public var position: Int32

}

extension CachedArticle : Identifiable { }
