//
//  CoreDataTestsStack.swift
//  Code Test Luis Garcia Tests
//
//  Created by Luis Garcia on 1/24/19.
//  Copyright © 2019 Luis Garcia. All rights reserved.
//

import XCTest
import CoreData

@testable import Code_Test_Luis_Garcia

class CoreDataTestsStack {
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContextSpy
    let mainContext: NSManagedObjectContextSpy
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Code_Test_Luis_Garcia")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType
        persistentContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
                fatalError("was unable to lead store \(error!)")
            }
        }
        
        mainContext = NSManagedObjectContextSpy(concurrencyType: .mainQueueConcurrencyType)
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        backgroundContext = NSManagedObjectContextSpy(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = self.mainContext
    }
}

class NSManagedObjectContextSpy: NSManagedObjectContext {
    var expectation: XCTestExpectation?
    var saveWasCalled = false
    
    override func performAndWait(_ block: () -> Void) {
        super.performAndWait(block)
        expectation?.fulfill()
    }
    
    override func save() throws {
        try super.save()
        
        saveWasCalled = true
    }
}
