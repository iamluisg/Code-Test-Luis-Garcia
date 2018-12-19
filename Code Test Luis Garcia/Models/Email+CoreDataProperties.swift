//
//  Email+CoreDataProperties.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//
//

import Foundation
import CoreData


extension Email {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Email> {
        return NSFetchRequest<Email>(entityName: "Email")
    }

    @NSManaged public var address: String
    @NSManaged public var type: String
    @NSManaged public var contact: Contact

}
