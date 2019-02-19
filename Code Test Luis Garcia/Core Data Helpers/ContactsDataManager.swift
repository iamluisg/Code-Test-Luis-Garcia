//
//  ContactsDataManager.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 1/24/19.
//  Copyright © 2019 Luis Garcia. All rights reserved.
//

import Foundation
import CoreData

class ContactsDataManager {
    let backgroundContext: NSManagedObjectContext
    
    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        self.backgroundContext = backgroundContext
    }
    
    func saveContact(firstName: String, lastName: String, dob: Date?, completion: @escaping (Contact?, NSError?) -> ()) {
        backgroundContext.performAndWait {
            let contact = Contact(context: backgroundContext)
            contact.firstName = firstName
            contact.lastName = lastName
            if let dob = dob {
                contact.dob = dob as NSDate
            }
            do {
                try backgroundContext.save()
                completion(contact, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
    
    func update(firstName: String, lastName: String, dob: Date?, of contact: Contact, completion: @escaping (Contact?, NSError?) -> ()) {
        let context = contact.managedObjectContext
        context?.performAndWait {
            contact.setValue(firstName, forKey: "firstName")
            contact.setValue(lastName, forKey: "lastName")
            if let dob = dob {
                contact.setValue(dob as NSDate, forKey: "dob")
            }
            do {
                try context?.save()
                completion(contact, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
    
    func addEmailTo(contact: Contact, address: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        guard let context = contact.managedObjectContext else {
            completion(nil, NSError(domain: "00", code: 00, userInfo: nil))
            return
        }
        context.performAndWait {
            let email = Email(context: context)
            email.address = address
            email.type = type
            email.contact = contact
            
            contact.addToEmail(email)
            
            do {
                try context.save()
                completion(contact, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
    
    func addPhoneTo(contact: Contact, number: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        guard let context = contact.managedObjectContext else {
            completion(nil, NSError(domain: "00", code: 00, userInfo: nil))
            return
        }
        context.performAndWait {
            let phone = Phone(context: context)
            phone.number = number
            phone.type = type
            phone.contact = contact
            
            contact.addToPhone(phone)
            
            do {
                try context.save()
                completion(contact, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }

    func addAddressTo(contact: Contact, street: String, streetDetail: String?, city: String, state: String, zip: String, type: String, completion: @escaping (Contact?, NSError?) -> ()) {
        
        guard let context = contact.managedObjectContext else {
            completion(nil, NSError(domain: "00", code: 00, userInfo: nil))
            return
        }
        
        context.performAndWait {
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
                completion(contact, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
    
    func deleteNSManagedObject(object: NSManagedObject, completion: @escaping(NSError?) -> ()) {
        guard let context = object.managedObjectContext else {
            completion(NSError(domain: "00", code: 00, userInfo: nil))
            return
        }
        context.performAndWait {
            context.delete(object)
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
}
