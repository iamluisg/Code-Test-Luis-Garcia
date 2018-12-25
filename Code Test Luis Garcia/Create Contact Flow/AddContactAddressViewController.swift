//
//  AddContactAddressViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/21/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class AddContactAddressViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var streetDetailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeTextField: UITextField!
    
    private var contactInfoTypes = ContactInfoType.allValues
    private var addressObjects = [Address]()
    private var activeTextField: UITextField?
    private var contactInfoTypePickerView = UIPickerView()
    
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
        self.nameLabel.text = "Add addresses for \(self.contact.fullName)"
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: AddressTableViewCell.identifier)
        
        guard let addresses: [Address] = self.contact.address.allObjects as? [Address] else {
            return
        }
        self.addressObjects = addresses.sorted(by: {$0.type < $1.type})
        self.setTypeTextFieldPicker()
        self.setNavigationButton()
    }
    
    func setTypeTextFieldPicker() {
        self.contactInfoTypePickerView.delegate = self
        self.contactInfoTypePickerView.dataSource = self
        self.typeTextField.inputView = self.contactInfoTypePickerView
    }

    func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self,
                                        action: #selector(completeAddContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    func refreshPageWith(contact: Contact) {
        guard var addresses: [Address] = contact.address.allObjects as? [Address] else {
            return
        }
        addresses.sort(by: {$0.type < $1.type})
        self.addressObjects = addresses
        self.tableView.reloadData()
    }
    
    @objc func completeAddContact() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeTextField?.resignFirstResponder()
        self.activeTextField = nil
    }
    //MARK: - User actions
    
    @IBAction func saveAddress(_ sender: Any) {
        self.activeTextField?.resignFirstResponder()
        guard let street = self.streetTextField.text, let city = self.cityTextField.text, let state = self.stateTextField.text, let zip = self.zipTextField.text, let type = self.typeTextField.text else {
            self.presentAlert(title: "Error", message: "Street, City, State, and Zip code fields are required to save.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return
        }
        
        if Validate.isStringEmpty(street) && Validate.isStringEmpty(city) && Validate.isStringEmpty(state) && Validate.isStringEmpty(zip) {
            return
        }
        
        CoreDataManager.shared.addAddressTo(contact: self.contact, street: street, streetDetail: self.streetDetailTextField.text, city: city, state: state, zip: zip, type: type) { [weak self] (contact, error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not successfully save your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            } else {
                self?.streetTextField.text = nil
                self?.streetDetailTextField.text = nil
                self?.cityTextField.text = nil
                self?.stateTextField.text = nil
                self?.zipTextField.text = nil
                self?.typeTextField.text = nil
                self?.contactInfoTypePickerView.selectRow(0, inComponent: 0, animated: false)
                guard let contact = contact else { return }
                self?.refreshPageWith(contact: contact)
            }
        }
    }
    
    func deleteAddress(object: Address, at indexPath: IndexPath) {
        CoreDataManager.shared.deleteNSManagedObject(object: object) { [weak self] (error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not delete the object. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
            }
            self?.addressObjects.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


extension AddContactAddressViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddressTableViewCell.identifier, for: indexPath) as! AddressTableViewCell
        
        let addressObject = self.addressObjects[indexPath.row]
        cell.streetTextField.text = addressObject.street
        cell.streetDetailTextField.text = addressObject.streetDetail
        cell.cityTextField.text = addressObject.city
        cell.stateTextField.text = addressObject.state
        cell.zipTextField.text = addressObject.zip
        cell.addressTypeLabel.text = addressObject.type
        
        cell.deleteAddressCell = { [weak self] cell in
            self?.deleteAddress(object: addressObject, at: indexPath)
        }
        
        return cell
    }
}

extension AddContactAddressViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
            self.typeTextField.text = nil
        } else {
            self.typeTextField.text = contactInfoTypes[row].rawValue
        }
    }
}

extension AddContactAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
}
