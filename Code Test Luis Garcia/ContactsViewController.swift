//
//  ContactsViewController.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    
    private lazy var emptyStateView: EmptyStateView? = nil
    private let context = CoreDataManager.shared.persistentContainer.viewContext
    private var fetchedContacts: NSFetchedResultsController<Contact>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        self.contactsTableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: ContactsTableViewCell.identifier)
        self.fetchContacts()
        self.setNavigationButton()
        
        NotificationCenter.default.addObserver(forName: .refreshContactList, object: nil, queue: nil) { [weak self] (note) in
            self?.fetchContacts()
            self?.contactsTableView.reloadData()
        }
        
        
//        NotificationCenter.default.addObserver(for: NotificationCenter.refreshContactList, object: nil, queue: nil) { [weak self] in
//            self?.fetchContacts()
//            self?.contactsTableView.reloadData()
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshContactList, object: nil)
    }

    func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    func fetchContacts() {
        let request = Contact.fetchRequest() as NSFetchRequest<Contact>
        
        let sort = NSSortDescriptor(key: #keyPath(Contact.lastName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do {
            self.fetchedContacts = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            try self.fetchedContacts.performFetch()
        } catch {
            self.presentAlert(title: "Error", message: "Could not successfully retrieve your contacts. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    //MARK: - User Actions
    @objc func addContact() {
        self.navigationController?.pushViewController(AddContactViewController(), animated: true)
    }

}


extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objs = fetchedContacts.fetchedObjects else { return 0 }
        if objs.count == 0 {
            self.addEmptyStateView(tableView, with: "You currently have no contacts. Please add contacts by tapping on the plus button above to view them here.")
            return 0
        } else {
            self.removeEmptyStateViewFrom(tableView)
            return objs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.identifier, for: indexPath) as! ContactsTableViewCell
        let contact = self.fetchedContacts.object(at: indexPath)
        cell.nameLabel.text = contact.fullName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = self.fetchedContacts.object(at: indexPath)
            CoreDataManager.shared.deleteContact(contact: contact) { (error) in
                if error != nil {
                    self.presentAlert(title: "Error", message: "Could not successfully delete your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                    return
                }
                self.fetchContacts()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.fetchedContacts.object(at: indexPath)
        let emails = contact.email.allObjects
        for email in emails {
            if let x = email as? Email {
                print(x.address)
            }
        }
        let phones = contact.phone.allObjects
        for phone in phones {
            if let p = phone as? Phone {
                print(p.number)
            }
        }
        let addresses = contact.address.allObjects
        for address in addresses {
            if let a = address as? Address {
                print(a.street)
            }
        }
        
    }
    
    func addEmptyStateView(_ tableView: UITableView, with message: String) {
        if self.emptyStateView == nil {
            self.emptyStateView = EmptyStateView(frame: tableView.frame)
            self.emptyStateView?.messageLabel.text = message
            tableView.separatorStyle = .none
            tableView.backgroundView = self.emptyStateView
        }
    }
    
    func removeEmptyStateViewFrom(_ tableView: UITableView) {
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = nil
        self.emptyStateView = nil
    }
    
    
}
