//
//  AddContactViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    
    private var dobPicker = UIDatePicker()
    private lazy var activeTextField: UITextField? = nil
    private let dobToolbar: UIToolbar = UIToolbar()
    private var dob: Date?
    
    //MARK: - UIViewControler Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Contact"
        self.setDOBDatePicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - View Controller Setup
    func setDOBDatePicker() {
        self.dobPicker.datePickerMode = .date
        self.dobPicker.maximumDate = Date()
        self.dobPicker.addTarget(self, action: #selector(setDOBText(sender:)), for: .valueChanged)
        self.dobTextField.inputView = self.dobPicker
        
        self.dobToolbar.barStyle = UIBarStyle.default
        self.dobToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeDOBPicker)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneDOBTextField))
        ]
        
        self.dobToolbar.sizeToFit()
        self.dobTextField.inputAccessoryView = self.dobToolbar
    }
    
    //MARK: - Validation methods
    func validate(firstName: String, lastName: String) -> Bool {
        if Validate.isStringEmpty(firstName) || Validate.isStringEmpty(lastName) {
            self.presentAlert(title: "Empty Field", message: "Please fill in both First and Last names to save your contact.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return false
        }
        return true
        
    }
    
    //MARK: - User Actions
    @objc func closeDOBPicker() {
        self.dobTextField.text = nil
        self.dobTextField.resignFirstResponder()
    }
    
    @objc func doneDOBTextField() {
        self.dobTextField.resignFirstResponder()
    }

    @objc func setDOBText(sender: UIDatePicker) {
        self.dobTextField.text = Date().getFormattedStringFromDate(date: self.dobPicker.date)
    }
   
    
    @IBAction func saveContact(_ sender: Any) {
        self.activeTextField?.resignFirstResponder()
        
        guard let firstName = self.firstNameTextField.text, let lastName = self.lastNameTextField.text else {
                self.presentAlert(title: "Empty Field", message: "Please fill in both First and Last names to save your contact.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
        }
        guard self.validate(firstName: firstName, lastName: lastName) == true else {
            return
        }
        var dob: Date? = nil
        if let _ = self.dobTextField.text {
            dob = self.dobPicker.date
        }
        
        CoreDataManager.shared.saveContact(firstName: firstName, lastName: lastName, dob: dob) { (contact, error) in
            if error != nil {
                self.presentAlert(title: "Error", message: "Could not successfully save your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            } else {
                NotificationCenter.default.post(name: .refreshContactList, object: nil, userInfo: nil)
                guard let contact = contact else {
                    return
                }
                self.presentAddDetailsOptionTo(contact: contact)
            }
        }
    }
    
    func presentAddDetailsOptionTo(contact: Contact) {
        self.presentAlert(title: "Successfully Saved", message: "Would you like to add details to your contact?", type: .Alert, actions: [("Not Now", .cancel), ("Yes", .default)], completionHandler: { (response) in
            switch response {
            case 0:
                self.navigationController?.popViewController(animated: true)
                return
            case 1:
                self.firstNameTextField.text = nil
                self.lastNameTextField.text = nil
                self.dobTextField.text = nil
                self.navigationController?.pushViewController(AddContactPhoneViewController(contact: contact), animated: true)
                return
            default:
                return
            }
        } )
    }
    
}

extension AddContactViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            self.lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            self.dobTextField.becomeFirstResponder()
        default:
            return resignFirstResponder()
        }
        return true
    }
}

extension AddContactViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }    
}


