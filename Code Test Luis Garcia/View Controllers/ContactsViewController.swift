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
    @IBOutlet weak var searchBar: UISearchBar!
    
    private lazy var emptyStateView: EmptyStateView? = nil
    private let context = CoreDataManager.shared.persistentContainer.viewContext
    private var fetchedContacts: NSFetchedResultsController<Contact>!
    private var isFiltered = false
    private var query = ""
    
    //MARK: UIViewController lifecycle methods
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshContactList, object: nil)
    }

    private func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    private func fetchContacts() {
        let request = Contact.fetchRequest() as NSFetchRequest<Contact>
        if !query.isEmpty {
            let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", query)
            let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", query)
            request.predicate = NSCompoundPredicate(type: .or, subpredicates: [lastNamePredicate, firstNamePredicate])
        }
        let sort = NSSortDescriptor(key: #keyPath(Contact.lastName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do {
            self.fetchedContacts = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchedContacts.delegate = self
            try self.fetchedContacts.performFetch()
        } catch {
            self.presentAlert(title: "Error", message: "Could not successfully retrieve your contacts. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
        }
    }
    
    //MARK: - User Actions
    @objc private func addContact() {
        self.navigationController?.pushViewController(AddContactViewController(), animated: true)
    }
    
    private func deleteContact(object: Contact, at indexPath: IndexPath) {
        CoreDataManager.shared.deleteNSManagedObject(object: object) { (error) in
            if error != nil {
                self.presentAlert(title: "Error", message: "Could not successfully delete your contact. Please try again.", type: .Alert, actions: [("Done", .default)], completionHandler: nil)
                return
            }
        }
    }

}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objs = fetchedContacts.fetchedObjects else { return 0 }
        if objs.count == 0 {
            if self.isFiltered {
                self.addEmptyStateView(tableView, with: "You have no contacts that match your search. Please try a different search.")
            } else {
                self.addEmptyStateView(tableView, with: "You currently have no contacts. Please add contacts by tapping on the plus button above to view them here.")
            }
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
            self.deleteContact(object: contact, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = self.fetchedContacts.object(at: indexPath)
        self.navigationController?.pushViewController(ContactDetailViewController(contact: contact), animated: true)
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

extension ContactsViewController: UISearchBarDelegate {
    private func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.isFiltered = true
        self.query = text
        self.fetchContacts()
        searchBar.resignFirstResponder()
        self.contactsTableView.reloadData()
        
    }
    
    private func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isFiltered = false
        query = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.fetchContacts()
        self.contactsTableView.reloadData()
    }
    
    private func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            query = ""
            searchBar.text = nil
            self.fetchContacts()
            self.contactsTableView.reloadData()
        }
    }
}

extension ContactsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else {
            return
        }
        
        switch type {
        case .delete:
            self.contactsTableView.deleteRows(at: [cellIndex], with: .fade)
        default:
            return
        }
    }
}
