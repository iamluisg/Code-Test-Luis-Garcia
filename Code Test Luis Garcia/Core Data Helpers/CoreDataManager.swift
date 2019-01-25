//
//  CoreDataManager.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataConfiguration {
    case production
    case test
}

class CoreDataManager {
    
    private var storeType: String!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Code_Test_Luis_Garcia")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType
        
        return persistentContainer
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    static let shared = CoreDataManager()
    
    func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        loadPersistentStore {
            completion?()
        }
    }
    
    private func loadPersistentStore(completion: @escaping () -> Void) {
        persistentContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
                fatalError("was unable to load store \(String(describing: error?.localizedDescription))")
            }
            completion()
        }
    }
    
    func saveContact(firstName: String, lastName: String, dob: Date?, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let contact = Contact(context: context)
        contact.firstName = firstName
        contact.lastName = lastName
        if let dob = dob {
            contact.dob = dob as NSDate
        }
        do {
            try context.save()
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func update(firstName: String, lastName: String, dob: Date?, of contact: Contact, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        contact.setValue(firstName, forKey: "firstName")
        contact.setValue(lastName, forKey: "lastName")
        if let dob = dob {
            contact.setValue(dob as NSDate, forKey: "dob")
        }
        do {
            try context.save()
            context.refresh(contact, mergeChanges: true)
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func addEmailTo(contact: Contact, address: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let email = Email(context: context)
        email.address = address
        email.type = type
        email.contact = contact
        
        contact.addToEmail(email)
        
        do {
            try context.save()
            context.refresh(contact, mergeChanges: true)
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func addPhoneTo(contact: Contact, number: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let phone = Phone(context: context)
        phone.number = number
        phone.type = type
        phone.contact = contact
        
        contact.addToPhone(phone)
        
        do {
            try context.save()
            context.refresh(contact, mergeChanges: true)
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func addAddressTo(contact: Contact, street: String, streetDetail: String?, city: String, state: String, zip: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let address = Address(context: context)
        address.street = street
        if let streetDetail = streetDetail {
            address.streetDetail = streetDetail
        }
        address.city = city
        address.state = state
        address.zip = zip
        address.type = type
        address.contact = contact
        address.country = "USA"
        
        contact.addToAddress(address)
        
        do {
            try context.save()
            context.refresh(contact, mergeChanges: true)
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func deleteNSManagedObject(object: NSManagedObject, completion: @escaping(NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(object)
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error as NSError)
        }
    }
}

