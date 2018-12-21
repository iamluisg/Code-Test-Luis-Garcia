//
//  Validate.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation

struct Validate {
    /*
    Empty String Validator:
    - String is not nil
    - String is not "" or " "
    */
    static func isStringEmpty(_ string: String) -> Bool {
        let strippedString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if strippedString.isEmpty {
            return true
        }
        return false
    }
    
    /*
     Phone Validator:
     - United States phone number validaton only
     - Strips out all dashes parenthesis and spaces
     - Checks for numeric characters only
     - Checks for 10 digits
     */
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        
        let formattedPhone1 = phoneNumber.replacingOccurrences(of: "-", with: "")
        let formattedPhone2 = formattedPhone1.replacingOccurrences(of: "(", with: "")
        let formattedPhone3 = formattedPhone2.replacingOccurrences(of: ")", with: "")
        let formattedPhone4 = formattedPhone3.replacingOccurrences(of: " ", with: "")
        
        if formattedPhone4.count == 10 {
            let containsNumbers = "^[0-9]+$"
            let phoneTest = NSPredicate(format:"SELF MATCHES %@", containsNumbers)
            let result = phoneTest.evaluate(with: formattedPhone4)
            return result
        }
        
        return false
    }
    
    /*
     Email Validator:
     - Checks for an email with an alphanumeric name
     - Followed by an "@" symbol
     - Followed by an alphanumeric domain name
     - Followed by a "." symbol
     - Followed by a top level domain name (must be at least 2 characters and no longer than 12 characters)
     */
    static func isValidEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,12}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        
        return result
    }
}
