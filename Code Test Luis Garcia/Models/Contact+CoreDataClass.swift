//
//  Contact+CoreDataClass.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//
//

import Foundation
import CoreData


public class Contact: NSManagedObject {
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

}
