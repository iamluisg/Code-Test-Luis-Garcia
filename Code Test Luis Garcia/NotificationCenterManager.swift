//
//  NotificationCenterManager.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardShowHideProtocol {
    var showKeyboardToken: Token? { get }
    var hideKeyboardToken: Token? { get }
    
    func keyboardWillShow(payload: KeyboardNotificationPayload)
    func keyboardWillHide(payload: KeyboardNotificationPayload)
}

//MARK: - Functions that define the type of observation being signed up for
public struct NotificationCenterManager {
    static let keyboardWillShowNotification = NotificationDescriptor<KeyboardNotificationPayload>(name: Notification.Name("UIKeyboardWillShowNotification"), convert: {note in
        guard let userInfo = note.userInfo else { return KeyboardNotificationPayload(frame: CGRect.zero, animationDuration: 0) }
        guard let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) else { return KeyboardNotificationPayload(frame: CGRect.zero, animationDuration: 0) }
        let keyboardFrame: CGRect = keyboardEndFrame.cgRectValue
        
        var duration: Double = 0.35
        if let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            duration = animationDuration
        }
        return KeyboardNotificationPayload(frame: keyboardFrame, animationDuration: duration)
    })
    
    static let keyboardWillHideNotification = NotificationDescriptor<KeyboardNotificationPayload>(name: Notification.Name("UIKeyboardWillHideNotification"), convert: { note in
        guard let userInfo = note.userInfo else { return KeyboardNotificationPayload(frame: CGRect.zero, animationDuration: 0) }
        guard let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) else { return KeyboardNotificationPayload(frame: CGRect.zero, animationDuration: 0) }
        let keyboardFrame: CGRect = keyboardEndFrame.cgRectValue
        
        var duration: Double = 0.35
        if let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            duration = animationDuration
        }
        return KeyboardNotificationPayload(frame: keyboardFrame, animationDuration: duration)
    })
}

extension Notification.Name {
    static let refreshContactList = Notification.Name("RefreshContactList")
}

struct NotificationDescriptor<A> {
    let name: Notification.Name
    let convert: (Notification) -> A
}

public struct KeyboardNotificationPayload {
    let frame: CGRect
    let animationDuration: Double
}

//MARK: - Token which automatically removes observer upon deallocation of view controller
public class Token {
    let token: NSObjectProtocol
    let center: NotificationCenter
    
    fileprivate init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    @discardableResult
    func addObserver<A>(descriptor: NotificationDescriptor<A>, using block: @escaping (A) -> ()) -> Token {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil, using: { note in
            block(descriptor.convert(note))
        })
        return Token(token: token, center: self)
    }
}
