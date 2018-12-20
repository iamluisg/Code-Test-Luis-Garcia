//
//  AddContactViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController {

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    
    private var dobPicker = UIDatePicker()
    private lazy var activeTextField: UITextField? = nil
    private let dobToolbar: UIToolbar = UIToolbar()
    private var dob: Date?
    
    private var emailArray: [String] = [String]()
    private var phoneArray: [String] = [String]()
    private var addressArray: [[String: String]] = [[:]]
    private var sections = ["Person", "Phone Numbers", "Email Addresses", "Addresses"]
    
    internal lazy var showKeyboardToken: Token? = nil
    internal lazy var hideKeyboardToken: Token? = nil
    
    //MARK: - UIViewControler Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Contact"
//        self.setDOBDatePicker()
        self.registerTableViewCells()
        self.setupKeyboardShowAndHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailArray.removeAll()
        self.phoneArray.removeAll()
        self.addressArray.removeAll()
    }
    
    //MARK: - View Controller Setup
    func setDOBDatePicker(for textField: UITextField) {
        self.dobPicker.datePickerMode = .date
        self.dobPicker.maximumDate = Date()
        self.dobPicker.addTarget(self, action: #selector(setDOBText(sender:)), for: .valueChanged)
        textField.inputView = self.dobPicker
        
        self.dobToolbar.barStyle = UIBarStyle.default
        self.dobToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeDOBPicker)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneDOBTextField))
        ]
        
        self.dobToolbar.sizeToFit()
        textField.inputAccessoryView = self.dobToolbar
    }
    
    func registerTableViewCells() {
        self.tableView.register(UINib(nibName: "EmailTableViewCell", bundle: nil), forCellReuseIdentifier: EmailTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "PhoneTableViewCell", bundle: nil), forCellReuseIdentifier: PhoneTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: AddressTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "ContactInfoTableViewCell", bundle: nil), forCellReuseIdentifier: ContactInfoTableViewCell.identifier)
        self.tableView.register(UINib(nibName: "AddCellView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AddCellView")
    }
    
    func setupKeyboardShowAndHide() {
        self.showKeyboardToken = NotificationCenter.default.addObserver(descriptor: NotificationCenterManager.keyboardWillShowNotification, using: {
            [weak self] in
            self?.keyboardWillShow(payload: $0)
        })
        
        self.hideKeyboardToken = NotificationCenter.default.addObserver(descriptor: NotificationCenterManager.keyboardWillHideNotification, using: { [weak self] in
            self?.keyboardWillHide(payload: $0)
        })
    }
    
    func keyboardWillShow(payload: KeyboardNotificationPayload) {
        let keyboardHeight = payload.frame.height
        UIView.animate(withDuration: payload.animationDuration) {
            self.tableViewBottomConstraint.constant = keyboardHeight
        }
    }
    
    func keyboardWillHide(payload: KeyboardNotificationPayload) {
        UIView.animate(withDuration: payload.animationDuration) {
            self.tableViewBottomConstraint.constant = 0
        }
    }
    
    //MARK: - Validation methods
    func validate(firstName: String, lastName: String) -> Bool {
        if Validate.isStringEmpty(firstName) || Validate.isStringEmpty(lastName) {
            self.presentAlert(title: "Empty Field", message: "Please fill in both First and Last names to save your contact.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return false
        }
        return true
        
    }
    
    func presentAddDetailsAlert() {
        
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
                guard let contact = contact else {
                    print("died in guard")
                    return
                }
                let context = CoreDataManager.shared.persistentContainer.viewContext
                let email = Email(context: context)
                email.address = "gogogo@go.com"
                email.type = "home"
                email.contact = contact
                do {
                    try context.save()
                } catch {
                    
                }
                NotificationCenter.default.post(name: .refreshContactList, object: nil, userInfo: nil)
//                self.presentAlert(title: "Successfully Saved", message: "Would you like to add details to your contact?", type: .Alert, actions: [("Not Now", .cancel), ("Yes", .default)], completionHandler: { (response) in
//                    switch response {
//                    case 0:
//                        self.navigationController?.popViewController(animated: true)
//                        return
//                    case 1:
//                        self.addContactDetails()
//                        return
//                    default:
//                        return
//                    }
//                } )
            }
        }
    }
    
    func addContactDetails() {
        
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


extension AddContactViewController: AddCellDelegate {
    func addCellToSection(section: Int) {
        switch section {
        case 1:
            self.phoneArray.append("")
        case 2:
            self.emailArray.append("")
        case 3:
            self.addressArray.append([:])
        default:
            return
        }
        self.tableView.reloadData()
    }
}

extension AddContactViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 160
        case 1, 2:
            return 50
        case 3:
            return 225
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddCellView") as! AddCellView
            cell.addMessageLabel.text = "Phone - Tap to add"
            cell.section = section
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddCellView") as! AddCellView
            cell.addMessageLabel.text = "Email - Tap to add"
            cell.section = section
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddCellView") as! AddCellView
            cell.addMessageLabel.text = "Address - Tap to add"
            cell.section = section
            cell.delegate = self
            return cell
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return phoneArray.count
        case 2:
            return emailArray.count
        case 3:
            return addressArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactInfoTableViewCell.identifier, for: indexPath) as! ContactInfoTableViewCell
            self.setDOBDatePicker(for: cell.dobTextField)
            cell.dobTextField.delegate = self
            cell.firstNameTextField.delegate = self
            cell.lastNameTextField.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhoneTableViewCell.identifier, for: indexPath) as! PhoneTableViewCell
            cell.deletePhoneCell = { [weak self] (_) in
                self?.phoneArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([indexPath.section], with: .none)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.identifier, for: indexPath) as! EmailTableViewCell
            cell.deleteEmailCell = { [weak self] (_) in
                self?.emailArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([indexPath.section], with: .none)
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressTableViewCell.identifier, for: indexPath) as! AddressTableViewCell
            cell.deleteAddressCell = { [weak self] (_) in
                self?.addressArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([indexPath.section], with: .none)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
