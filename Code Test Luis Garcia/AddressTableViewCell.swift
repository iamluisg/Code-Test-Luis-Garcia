//
//  AddressTableViewCell.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/20/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var streetLabel: UITextField!
    @IBOutlet weak var streetDetailLabel: UITextField!
    @IBOutlet weak var cityLabel: UITextField!
    @IBOutlet weak var stateLabel: UITextField!
    @IBOutlet weak var zipLabel: UITextField!
    
    var deleteAddressCell: ((UITableViewCell) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteAddressCell(_ sender: Any) {
        deleteAddressCell?(self)
    }
    
    
}
