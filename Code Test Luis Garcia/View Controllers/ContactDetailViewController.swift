//
//  ContactDetailViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/24/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit
import MessageUI
import MapKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var phoneArray = [Phone]()
    private var emailArray = [Email]()
    private var addressArray = [Address]()
    private var contactDetailHeaderView: ContactDetailHeaderView?
    
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
        self.addEditButton()
    }
    
    private func registerTableViewCells() {
        self.tableView.register(UINib(nibName: "EmailTableViewCell", bundle: nil), forCellReuseIdentifier: EmailTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "PhoneTableViewCell", bundle: nil), forCellReuseIdentifier: PhoneTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: AddressTableViewCell.identifier)
    }
    
    private func addEditButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                        target: self,
                                        action: #selector(showEditActionSheet))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
 
    //MARK: - Helper methods
    private func editNameAndDOB() {
        let addContactVC = AddContactViewController(contact: self.contact, isEditing: true)
        addContactVC.didUpdateContact = { [weak self] (contact) in
            self?.contact = contact
            self?.setDetailObjects()
        }
        self.present(addContactVC, animated: true, completion: nil)
    }
    
    private func editPhoneNumbers() {
        let phoneNumbersVC = AddContactPhoneViewController(contact: self.contact, isEditing: true)
        phoneNumbersVC.didUpdateContact = { [weak self] (contact) in
            self?.contact = contact
            self?.setDetailObjects()
        }
        self.present(phoneNumbersVC, animated: true, completion: nil)
    }
    
    private func editEmailAddresses() {
        let emailAddressesVC = AddContactEmailViewController(contact: self.contact, isEditing: true)
        emailAddressesVC.didUpdateContact = { [weak self] (contact) in
            self?.contact = contact
            self?.setDetailObjects()
        }
        self.present(emailAddressesVC, animated: true, completion: nil)
    }
    
    private func editAddresses() {
        let addressesVC = AddContactAddressViewController(contact: self.contact, isEditing: true)
        addressesVC.didUpdateContact = { [weak self] (contact) in
            self?.contact = contact
            self?.setDetailObjects()
        }
        self.present(addressesVC, animated: true, completion: nil)
    }
    
    private func setDetailObjects() {
        if self.contactDetailHeaderView == nil {
            self.contactDetailHeaderView = ContactDetailHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 120))
            self.tableView.tableHeaderView = self.contactDetailHeaderView
        }
        self.contactDetailHeaderView?.nameLabel.text = self.contact.fullName
        if let date = self.contact.dob as Date? {
            self.contactDetailHeaderView?.dobLabel.text = Date().getFormattedStringFromDate(date: date)
        } else {
            self.contactDetailHeaderView?.dobLabel.text = "N/A"
        }
        
        guard let emails = self.contact.email.allObjects as? [Email] else { return }
        self.emailArray = emails.sorted(by: { $0.type < $1.type })
        guard let phones = self.contact.phone.allObjects as? [Phone] else { return }
        self.phoneArray = phones.sorted(by: { $0.type < $1.type })
        guard let addresses = self.contact.address.allObjects as? [Address] else { return }
        self.addressArray = addresses.sorted(by: { $0.type < $1.type })
        
        self.tableView.reloadData()
    }
    
    //MARK: - User actions
    @objc private func showEditActionSheet() {
        self.presentAlert(title: "What would you like to edit?", message: nil, type: .ActionSheet, actions: [("Edit Name/DOB", .default), ("Edit Phone Numbers", .default), ("Edit Email Addresses", .default), ("Edit Addresses", .default), ("Cancel", .cancel)]) { (response) in
            switch response {
            case 0:
                self.editNameAndDOB()
                return
            case 1:
                self.editPhoneNumbers()
                return
            case 2:
                self.editEmailAddresses()
                return
            case 3:
                self.editAddresses()
                return
            default: return
            }
        }
    }
    
    private func placeCallTo(phoneNumber: String) {
        if let url = URL(string: "tel://1\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.presentAlert(title: "Error", message: "Could not complete call to the specified phone number. Please make sure the number is valid.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    private func sendMessageTo(phoneNumber: String) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = [phoneNumber]
            self.present(composeVC, animated: true, completion: nil)
        } else {
            self.presentAlert(title: "Error", message: "Sorry, but messages cannot be sent from this device.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    private func sendEmailTo(address: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients([address])
            self.present(mailVC, animated: true, completion: nil)
        } else {
            self.presentAlert(title: "Error", message: "Sorry, but messages cannot be sent from this device.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    private func openMapsTo(address: Address) {
        let street = address.street.replacingOccurrences(of: " ", with: "+")
        let city = address.city.replacingOccurrences(of: " ", with: "+")
        let state = address.state
        let zip = address.zip
        if let url =  URL(string:"http://maps.apple.com/?address=\(street),\(city),\(state),\(zip)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.presentAlert(title: "Error", message: "Sorry, but we could not open this address.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    private func getDirectionsTo(address: Address) {
        let street = address.street.replacingOccurrences(of: " ", with: "+")
        let city = address.city.replacingOccurrences(of: " ", with: "+")
        let state = address.state
        let zip = address.zip
        if let url =  URL(string:"http://maps.apple.com/?daddr=\(street),\(city),\(state),\(zip)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.presentAlert(title: "Error", message: "Sorry, but we could not open this address.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }

}

extension ContactDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if self.phoneArray.count == 0 {
                return "Edit contact to add phone numbers"
            }
            return "Phone numbers"
        case 1:
            if self.emailArray.count == 0 {
                return "Edit contact to add email addresses"
            }
            return "Email addresses"
        case 2:
            if self.addressArray.count == 0 {
                return "Edit contact to add addresses"
            }
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
            cell.deleteCellButton.isHidden = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.identifier, for: indexPath) as! EmailTableViewCell
            let emailObject = self.emailArray[indexPath.row]
            cell.emailTextField.text = emailObject.address
            cell.typeTextField.text = emailObject.type
            cell.deleteCellButton.isHidden = true
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
            cell.deleteCellButton.isHidden = true
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let phoneObject = self.phoneArray[indexPath.row]
            self.presentAlert(title: "Please select action", message: nil, type: .ActionSheet, actions: [("Message \(phoneObject.number)", .default),("Call \(phoneObject.number)", .default), ("Cancel", .cancel)]) { (response) in
                switch response {
                case 0:
                    self.sendMessageTo(phoneNumber: phoneObject.number)
                    return
                case 1:
                    self.placeCallTo(phoneNumber: phoneObject.number)
                    return
                default:
                    return
                }
            }
            return
        case 1:
            let emailObject = self.emailArray[indexPath.row]
            self.presentAlert(title: "Please select action", message: nil, type: .ActionSheet, actions: [("Email \(emailObject.address)", .default), ("Cancel", .cancel)]) { (response) in
                switch response {
                case 0:
                    self.sendEmailTo(address: emailObject.address)
                    return
                default:
                    return
                }
            }
            return
        case 2:
            let addressObject = self.addressArray[indexPath.row]
            self.presentAlert(title: "Please select action", message: nil, type: .ActionSheet, actions: [("Open Maps to \(addressObject.street)", .default), ("Get directions to \(addressObject.street)", .default), ("Cancel", .cancel)]) { (response) in
                switch response {
                case 0:
                    self.openMapsTo(address: addressObject)
                    return
                case 1:
                    self.getDirectionsTo(address: addressObject)
                default:
                    return
                }
            }
        default:
            return
        }
    }
    
}

extension ContactDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ContactDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .failed:
            self.presentAlert(title: "Error", message: "Sorry, but your email failed to send. Please try again.", type: .Alert, actions: [("Done", .default)]) { (_) in
                controller.dismiss(animated: true, completion: nil)
            }
        default:
            controller.dismiss(animated: true, completion: nil)
        }
    }
}


