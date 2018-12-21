//
//  EmailTableViewCell.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/20/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class EmailTableViewCell: UITableViewCell {

    @IBOutlet weak var emailTextField: UITextField!
    
    var deleteEmailCell: ((UITableViewCell) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteEmailCell(_ sender: Any) {
        deleteEmailCell?(self)
    }
    
    
}
