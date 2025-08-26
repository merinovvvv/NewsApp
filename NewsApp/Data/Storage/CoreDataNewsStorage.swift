//
//  CoreDataNewsStorage.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 26.08.25.
//

import UIKit
import CoreData

final class CoreDataNewsStorage {
    
    static let shared: CoreDataNewsStorage = CoreDataNewsStorage(); private init() { }
    
    //MARK: - Private
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - CRUD
    
}
