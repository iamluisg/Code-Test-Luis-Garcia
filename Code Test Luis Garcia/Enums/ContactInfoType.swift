//
//  ContactInfoType.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/21/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

enum ContactInfoType: String {
    case empty = ""
    case home = "home"
    case mobile = "mobile"
    case office = "office"
    case other = "other"
    
    static let allValues = [empty, home, mobile, office, other]
}
