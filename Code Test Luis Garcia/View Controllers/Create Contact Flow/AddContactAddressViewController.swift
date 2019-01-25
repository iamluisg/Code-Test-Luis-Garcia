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
    @IBOutlet weak var doneEditingButton: UIButton!
    
    private var contactInfoTypes = [ContactInfoType.empty, ContactInfoType.home, ContactInfoType.office]
    private lazy var states = statesArray
    private var statePickerView = UIPickerView()
    private var addressObjects = [Address]()
    private var activeTextField: UITextField?
    private var contactInfoTypePickerView = UIPickerView()
    
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
        self.nameLabel.text = "Add addresses for \(self.contact.fullName)"
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: AddressTableViewCell.identifier)
        
        guard let addresses: [Address] = self.contact.address.allObjects as? [Address] else {
            return
        }
        self.addressObjects = addresses.sorted(by: {$0.type < $1.type})
        self.setPickerViews()
        self.setNavigationButton()
        
        if self.isEditingContact {
            self.doneEditingButton.isHidden = false
        }
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func setPickerViews() {
        self.contactInfoTypePickerView.delegate = self
        self.contactInfoTypePickerView.dataSource = self
        self.typeTextField.inputView = self.contactInfoTypePickerView
        
        self.statePickerView.delegate = self
        self.statePickerView.dataSource = self
        self.stateTextField.inputView = self.statePickerView
    }

    private func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self,
                                        action: #selector(completeAddContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    private func refreshPageWith(contact: Contact) {
        guard var addresses: [Address] = contact.address.allObjects as? [Address] else {
            return
        }
        addresses.sort(by: {$0.type < $1.type})
        self.addressObjects = addresses
        self.tableView.reloadData()
    }
    
    @objc private func completeAddContact() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeTextField?.resignFirstResponder()
        self.activeTextField = nil
    }
    
    //MARK: - User actions
    @IBAction private func saveAddress(_ sender: Any) {
        self.activeTextField?.resignFirstResponder()
        guard let street = self.streetTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let city = self.cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let state = self.stateTextField.text, let zip = self.zipTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let type = self.typeTextField.text else {
            self.presentAlert(title: "Error", message: "Street, City, State, and Zip code fields are required to save.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
            return
        }
        if Validate.isStringEmpty(street) && Validate.isStringEmpty(city) && Validate.isStringEmpty(state) && Validate.isStringEmpty(zip) {
            return
        }
        if !Validate.isValidZipCode(postalCode: zip) {
            self.presentAlert(title: "Error", message: "Please enter a valid US zip code.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
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
    
    private func deleteAddress(object: Address, at indexPath: IndexPath) {
        CoreDataManager.shared.deleteNSManagedObject(object: object) { [weak self] (error) in
            if error != nil {
                self?.presentAlert(title: "Error", message: "Could not delete the object. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
            }
            self?.addressObjects.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            self?.tableView.reloadData()
        }
    }
    
    @IBAction private func completeEditing(_ sender: Any) {
        self.didUpdateContact?(self.contact)
        self.dismiss(animated: true, completion: nil)
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
        if pickerView == self.contactInfoTypePickerView {
            return self.contactInfoTypes.count
        } else {
            return self.states.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.contactInfoTypePickerView {
            if self.contactInfoTypes[row] == ContactInfoType.empty {
                return ""
            } else {
                return self.contactInfoTypes[row].rawValue
            }
        } else {
            let state = self.states[row]
            return state
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.contactInfoTypePickerView {
            if self.contactInfoTypes[row] == ContactInfoType.empty {
                self.typeTextField.text = nil
            } else {
                self.typeTextField.text = contactInfoTypes[row].rawValue
            }
        } else {
            let abbreviation = String(self.states[row].prefix(2))
            self.stateTextField.text = abbreviation
        }
    }
}

extension AddContactAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
}
