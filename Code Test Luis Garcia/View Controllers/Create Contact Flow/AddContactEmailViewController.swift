//
//  AddContactEmailViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/21/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactEmailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTypeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeActionButton: UIButton!
    
    private var contactInfoTypePickerView = UIPickerView()
    private var contactInfoTypes = ContactInfoType.allValues
    private var emailObjects = [Email]()
    private var activeTextField: UITextField?
    
    var contact: Contact!
    private var isEditingContact: Bool = false
    var didUpdateContact: ((Contact) -> ())?

    init(contact: Contact, isEditing: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.contact = contact
        self.isEditingContact = isEditing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "Add emails for \(self.contact.fullName)"
        self.tableView.register(UINib(nibName: "EmailTableViewCell", bundle: nil), forCellReuseIdentifier: EmailTableViewCell.identifier)
        
        guard let emails: [Email] = self.contact.email.allObjects as? [Email] else {
            return
        }
        self.emailObjects =  emails.sorted(by: {$0.type < $1.type})//emails.sort(by: {$0.type < $1.type})
        self.setTypeTextFieldPicker()
        self.setNavigationButton()
        
        if self.isEditingContact {
            self.completeActionButton.setTitle("Done Editing", for: .normal)
        }
    }
    
    func setTypeTextFieldPicker() {
        self.contactInfoTypePickerView.delegate = self
        self.contactInfoTypePickerView.dataSource = self
        self.emailTypeTextField.inputView = self.contactInfoTypePickerView
    }
    
    func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self,
                                        action: #selector(completeAddContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    @objc func completeAddContact() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeTextField?.resignFirstResponder()
        self.activeTextField = nil
    }
    
    func validateEmail(email: String) -> Bool {
        if Validate.isValidEmail(email) {
            return true
        } else {
            self.presentAlert(title: "Error", message: "Please use a valid email address.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return false
        }
    }
    
    func refreshPageWith(contact: Contact) {
        guard var emails: [Email] = contact.email.allObjects as? [Email] else {
            return
        }
        emails.sort(by: {$0.type < $1.type})
        self.emailObjects = emails
        self.tableView.reloadData()
    }
    
    //MARK: - User actions
    @IBAction func saveEmailAddress(_ sender: Any) {
        self.activeTextField?.resignFirstResponder()
        guard let email = self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let type = self.emailTypeTextField.text else {
            return
        }
        if Validate.isStringEmpty(type) || Validate.isStringEmpty(email) {
            self.presentAlert(title: "Error", message: "Please fill in both email and type fields to save.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
        guard self.validateEmail(email: email) else { return }
        
        CoreDataManager.shared.addEmailTo(contact: self.contact, address: email, type: type) { [weak self] (contact, error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not successfully save your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            } else {
                self?.emailTypeTextField.text = nil
                self?.emailTextField.text = nil
                self?.contactInfoTypePickerView.selectRow(0, inComponent: 0, animated: false)
                guard let contact = contact else { return }
                self?.refreshPageWith(contact: contact)
            }
        }
    }
    
    func deleteEmail(object: Email, at indexPath: IndexPath) {
        CoreDataManager.shared.deleteNSManagedObject(object: object) { [weak self] (error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not delete the object. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
            }
            self?.emailObjects.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if !self.isEditingContact {
            self.navigationController?.pushViewController(AddContactAddressViewController(contact: contact), animated: true)
        } else {
            self.didUpdateContact?(self.contact)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension AddContactEmailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emailObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.identifier, for: indexPath) as! EmailTableViewCell
        let emailObject = self.emailObjects[indexPath.row]
        cell.emailTextField.text = emailObject.address
        cell.typeTextField.text = emailObject.type
        
        cell.deleteEmailCell = { [weak self] cell in
            self?.deleteEmail(object: emailObject, at: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddContactEmailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.contactInfoTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.contactInfoTypes[row] == ContactInfoType.empty {
            return ""
        } else {
            return self.contactInfoTypes[row].rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.contactInfoTypes[row] == ContactInfoType.empty {
            self.emailTypeTextField.text = nil
        } else {
            self.emailTypeTextField.text = contactInfoTypes[row].rawValue
        }
    }
}

extension AddContactEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
}
