//
//  NotificationCenterManager.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let refreshContactList = Notification.Name("RefreshContactList")
}

struct NotificationDescriptor {
    let name: Notification.Name
}

extension NotificationCenter {
    @discardableResult
    func addObserver(for descriptor: NotificationDescriptor, object obj: Any?, queue: OperationQueue?, using block: @escaping () -> Void) -> NSObjectProtocol {
        return addObserver(forName: descriptor.name, object: obj, queue: queue, using: { (note) in
            block()
        })
    }
    
    static let refreshContactList = NotificationDescriptor(name: .refreshContactList)
}
