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
    
    func addEmailsTo(contact: Contact, emails: [String], completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let emailSet = NSSet()
        for address in emails {
            let email = Email(context: context)
            email.address = address
            email.type = "home"
            email.contact = contact
            emailSet.adding(email)
        }
        contact.addToEmail(emailSet)
        do {
            try context.save()
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
    
    func addPhonesTo(contact: Contact, phones: [String], completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let phoneSet = NSSet()
        for number in phones {
            let phone = Phone(context: context)
            phone.number = number
            phone.type = "home"
            phone.contact = contact
            phoneSet.adding(phone)
        }
        contact.addToPhone(phoneSet)
        do {
            try context.save()
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func addAddressesTo(contact: Contact, addresses: [[String: String]], completion: @escaping (Contact?, NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let addressSet = NSSet()
        for address in addresses {
            let addressContext = Address(context: context)
            guard let street = address["street"], let city = address["city"], let state = address["state"], let zip = address["zip"] else { continue }
            if let streetDetail = address["streetDetail"] {
                addressContext.streetDetail = streetDetail
            }
            addressContext.street = street
            addressContext.city = city
            addressContext.state = state
            addressContext.zip = zip
            addressContext.type = "home"
            addressContext.contact = contact
            addressSet.adding(addressContext)
        }
        contact.addToAddress(addressSet)
        do {
            try context.save()
            completion(contact, nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
    func deleteContact(contact: Contact, completion: @escaping (NSError?) -> ()) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(contact)
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error as NSError)
        }
    }
}

