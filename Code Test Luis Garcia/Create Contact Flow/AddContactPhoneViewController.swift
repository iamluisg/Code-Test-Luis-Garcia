//
//  AddContactPhoneViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/21/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactPhoneViewController: UIViewController {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contactTypeTextField: UITextField!
    
    private var contactInfoTypePickerView = UIPickerView()
    private var contactInfoTypes = ContactInfoType.allValues
    private var phoneObjects = [Phone]()
    private var activeTextField: UITextField?
    
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
        self.contactNameLabel.text = "Add phone numbers for \(self.contact.fullName)"
        self.tableView.register(UINib(nibName: "PhoneTableViewCell", bundle: nil), forCellReuseIdentifier: PhoneTableViewCell.identifier)
        
        guard var phoneNumbers: [Phone] = self.contact.phone.allObjects as? [Phone] else {
            return
        }
        phoneNumbers.sort(by: {$0.type < $1.type})
        
        self.setTypeTextFieldPicker()
        self.setNavigationButton()
    }
    
    func refreshPageWith(contact: Contact) {
        guard var phoneNumbers: [Phone] = contact.phone.allObjects as? [Phone] else {
            return
        }
        phoneNumbers.sort(by: {$0.type < $1.type})
        self.phoneObjects = phoneNumbers
        self.tableView.reloadData()
    }
    
    func setTypeTextFieldPicker() {
        self.contactInfoTypePickerView.delegate = self
        self.contactInfoTypePickerView.dataSource = self
        self.contactTypeTextField.inputView = self.contactInfoTypePickerView
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
    
    func validateNumber(number: String) -> Bool {
        return Validate.isValidPhoneNumber(number)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeTextField?.resignFirstResponder()
        self.activeTextField = nil
    }
    
    //MARK - User actions
    @IBAction func savePhoneNumber(_ sender: Any) {
        self.activeTextField?.resignFirstResponder()
        guard let phoneNumber = self.phoneTextField.text, let type = self.contactTypeTextField.text else {
            return
        }
        if Validate.isStringEmpty(type) {
            self.presentAlert(title: "Error", message: "Please fill in both phone and type fields to save.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return
        }
        let strippedNumber = phoneNumber.filter { $0 != "-" && $0 != "(" && $0 != ")"}
        if !Validate.isValidPhoneNumber(strippedNumber) {
            self.presentAlert(title: "Error", message: "Please use a valid phone number.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return
        }
        CoreDataManager.shared.addPhoneTo(contact: self.contact, number: strippedNumber, type: type) { [weak self] (contact, error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not successfully save your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            } else {
                self?.contactTypeTextField.text = nil
                self?.phoneTextField.text = nil
                self?.contactInfoTypePickerView.selectRow(0, inComponent: 0, animated: false)
                guard let contact = contact else { return }
                self?.refreshPageWith(contact: contact)
            }
        }
    }
    
    func deletePhoneNumber(object: Phone, at indexPath: IndexPath) {
        CoreDataManager.shared.deleteNSManagedObject(object: object) { [weak self] (error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not delete the object. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
            }
            self?.phoneObjects.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        self.phoneTextField.text = nil
        self.contactTypeTextField.text = nil
        self.navigationController?.pushViewController(AddContactEmailViewController(contact: self.contact), animated: true)
    }

}

extension AddContactPhoneViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contact.phone.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhoneTableViewCell.identifier, for: indexPath) as! PhoneTableViewCell
        let phoneObject = self.phoneObjects[indexPath.row]
        cell.phoneNumberLabel.text = phoneObject.number
        cell.phoneTypeLabel.text = phoneObject.type
        return cell
    }
    
}

extension AddContactPhoneViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
            self.contactTypeTextField.text = nil
        } else {
            self.contactTypeTextField.text = contactInfoTypes[row].rawValue
        }
    }
}

extension AddContactPhoneViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == self.phoneTextField) {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            
            if length == 0 || length > 10 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            
            if (length - index) > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
        } else {
            return true
        }
    }
}
