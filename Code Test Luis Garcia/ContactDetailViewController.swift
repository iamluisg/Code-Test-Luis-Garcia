//
//  ContactDetailViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/24/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var phoneArray = [Phone]()
    private var emailArray = [Email]()
    private var addressArray = [Address]()
    
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
        
        
        self.registerTableViewCells()
        self.setDetailObjects()
    }
    
    func registerTableViewCells() {
        self.tableView.register(UINib(nibName: "EmailTableViewCell", bundle: nil), forCellReuseIdentifier: EmailTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "PhoneTableViewCell", bundle: nil), forCellReuseIdentifier: PhoneTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: AddressTableViewCell.identifier)
    }
    
    func setDetailObjects() {
        let headerView = ContactDetailHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 120))
        headerView.nameLabel.text = self.contact.fullName
        if let date = self.contact.dob as Date? {
            headerView.dobLabel.text = Date().getFormattedStringFromDate(date: date)
        } else {
            headerView.dobLabel.text = "N/A"
        }
        self.tableView.tableHeaderView = headerView
        
        guard let emails = self.contact.email.allObjects as? [Email] else { return }
        self.emailArray = emails.sorted(by: { $0.type < $1.type })
        guard let phones = self.contact.phone.allObjects as? [Phone] else { return }
        self.phoneArray = phones.sorted(by: { $0.type < $1.type })
        guard let addresses = self.contact.address.allObjects as? [Address] else { return }
        self.addressArray = addresses.sorted(by: { $0.type < $1.type })
        
        self.tableView.reloadData()
    }

}

extension ContactDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Phone numbers"
        case 1:
            return "Email addresses"
        case 2:
            return "Addresses"
        default:
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.phoneArray.count
        case 1:
            return self.emailArray.count
        case 2:
            return self.addressArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhoneTableViewCell.identifier, for: indexPath) as! PhoneTableViewCell
            let phoneObject = self.phoneArray[indexPath.row]
            cell.phoneNumberLabel.text = phoneObject.number
            cell.phoneTypeLabel.text = phoneObject.type
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.identifier, for: indexPath) as! EmailTableViewCell
            let emailObject = self.emailArray[indexPath.row]
            cell.emailTextField.text = emailObject.address
            cell.typeTextField.text = emailObject.type
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressTableViewCell.identifier, for: indexPath) as! AddressTableViewCell
            let addressObject = self.addressArray[indexPath.row]
            cell.streetTextField.text = addressObject.street
            cell.streetDetailTextField.text = addressObject.streetDetail
            cell.cityTextField.text = addressObject.city
            cell.stateTextField.text = addressObject.state
            cell.zipTextField.text = addressObject.zip
            cell.addressTypeLabel.text = addressObject.type
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1:
            return 90
        case 2:
            return 160
        default:
            return 90
        }
    }
    
}
