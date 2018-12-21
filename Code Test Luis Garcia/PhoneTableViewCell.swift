//
//  PhoneTableViewCell.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/20/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class PhoneTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneTextField: UITextField!
    
    var deletePhoneCell: ((UITableViewCell) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func deletePhoneCell(_ sender: Any) {
        deletePhoneCell?(self)
    }
    
    
}
