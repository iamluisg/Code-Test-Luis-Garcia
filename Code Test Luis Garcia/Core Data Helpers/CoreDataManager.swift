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

