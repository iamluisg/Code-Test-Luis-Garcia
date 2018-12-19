//
//  UIViewControllerExtensions.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import Foundation
import UIKit

enum AlertType {
    case Alert, ActionSheet
}

extension UIViewController {
    
    func presentAlert(title: String?, message: String?, type: AlertType, actions: [(String, UIAlertAction.Style)]?, completionHandler: ((Int) -> ())?) {
        
        let preferredStyle: UIAlertController.Style = String(describing: type) == String(describing: AlertType.Alert) ? .alert : .actionSheet
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let actions = actions {
            for (index, action) in actions.enumerated() {
                
                alertController.addAction(UIAlertAction(title: action.0, style: action.1, handler: { (_) in
                    completionHandler?(index)
                }))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })
        }
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
