//
//  Contact+CoreDataProperties.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var dob: NSDate?
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var address: NSSet
    @NSManaged public var email: NSSet
    @NSManaged public var phone: NSSet

}

// MARK: Generated accessors for address
extension Contact {

    @objc(addAddressObject:)
    @NSManaged public func addToAddress(_ value: Address)

    @objc(removeAddressObject:)
    @NSManaged public func removeFromAddress(_ value: Address)

    @objc(addAddress:)
    @NSManaged public func addToAddress(_ values: NSSet)

    @objc(removeAddress:)
    @NSManaged public func removeFromAddress(_ values: NSSet)

}

// MARK: Generated accessors for email
extension Contact {

    @objc(addEmailObject:)
    @NSManaged public func addToEmail(_ value: Email)

    @objc(removeEmailObject:)
    @NSManaged public func removeFromEmail(_ value: Email)

    @objc(addEmail:)
    @NSManaged public func addToEmail(_ values: NSSet)

    @objc(removeEmail:)
    @NSManaged public func removeFromEmail(_ values: NSSet)

}

// MARK: Generated accessors for phone
extension Contact {

    @objc(addPhoneObject:)
    @NSManaged public func addToPhone(_ value: Phone)

    @objc(removePhoneObject:)
    @NSManaged public func removeFromPhone(_ value: Phone)

    @objc(addPhone:)
    @NSManaged public func addToPhone(_ values: NSSet)

    @objc(removePhone:)
    @NSManaged public func removeFromPhone(_ values: NSSet)

}
