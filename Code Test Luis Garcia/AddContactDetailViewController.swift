//
//  AddContactDetailViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactDetailViewController: UIViewController {

    var contact: Contact!
    
    init(contact: Contact) {
        super.init(nibName: nil, bundle: nil)
        self.contact = contact
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.contact.fullName
    }
    
    
}
