//
//  Phone+CoreDataProperties.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//
//

import Foundation
import CoreData


extension Phone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Phone> {
        return NSFetchRequest<Phone>(entityName: "Phone")
    }

    @NSManaged public var number: String
    @NSManaged public var type: String
    @NSManaged public var contact: Contact

}
