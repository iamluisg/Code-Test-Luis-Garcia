//
//  CoreDataManager.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Code_Test_Luis_Garcia")
        container.loadPersistentStores(completionHandler: { (store, error) in
            print(store)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContact(firstName: String, lastName: String, dob: Date?, completion: @escaping (NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let contact = Contact(context: context)
        contact.firstName = firstName
        contact.lastName = lastName
        if let dob = dob {
            contact.dob = dob as NSDate
        }
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error as NSError)
        }
    }
}

