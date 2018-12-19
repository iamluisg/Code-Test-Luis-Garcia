//
//  Address+CoreDataProperties.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var state: String
    @NSManaged public var street: String
    @NSManaged public var streetDetail: String?
    @NSManaged public var type: String
    @NSManaged public var zip: String
    @NSManaged public var contact: Contact

}
