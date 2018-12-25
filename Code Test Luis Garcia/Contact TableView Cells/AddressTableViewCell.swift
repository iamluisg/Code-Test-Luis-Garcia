//
//  AddressTableViewCell.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/20/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var streetTextField: UILabel!
    @IBOutlet weak var streetDetailTextField: UILabel!
    @IBOutlet weak var cityTextField: UILabel!
    @IBOutlet weak var stateTextField: UILabel!
    @IBOutlet weak var zipTextField: UILabel!
    
    @IBOutlet weak var addressTypeLabel: UILabel!
    var deleteAddressCell: ((UITableViewCell) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteAddressCell(_ sender: Any) {
        deleteAddressCell?(self)
    }
    
    
}
