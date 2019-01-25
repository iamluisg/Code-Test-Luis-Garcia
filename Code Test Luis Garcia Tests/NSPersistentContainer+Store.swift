//
//  NSPersistentContainer+Store.swift
//  Code Test Luis Garcia Tests
//
//  Created by Luis Garcia on 1/24/19.
//  Copyright © 2019 Luis Garcia. All rights reserved.
//

import Foundation
import CoreData
@testable import Code_Test_Luis_Garcia

extension NSPersistentContainer {
    func destroyPersistentStore() {
        guard let storeURL = persistentStoreDescriptions.first?.url, let storeType = persistentStoreDescriptions.first?.type else {
            return
        }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: storeType, options: nil)
        } catch let error {
            print("failed to destroy persistent store at \(storeURL), error: \(error)")
        }
    }
}
