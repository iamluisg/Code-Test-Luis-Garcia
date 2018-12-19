//
//  DateExtensions.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        let displayDate = dateFormatter.string(from: date)
        return displayDate
    }
}
