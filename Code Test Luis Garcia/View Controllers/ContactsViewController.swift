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
    
    fileprivate lazy var fetchedResultsDelegateHandler: TableViewFetchedResultsControllerDelegateHandler = {
       return TableViewFetchedResultsControllerDelegateHandler(tableView: self.contactsTableView)
    }()
    
    fileprivate let sortDescriptor = NSSortDescriptor(key: #keyPath(Contact.lastName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Contact> = {
        let fetchRequest: NSFetchRequest = Contact.fetchRequest()
        fetchRequest.sortDescriptors = [self.sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self.fetchedResultsDelegateHandler
        
        self.defaultResultsController = fetchedResultsController
        
        return fetchedResultsController
    }()
    
    fileprivate var defaultResultsController: NSFetchedResultsController<Contact>?
    
    //MARK: UIViewController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        self.contactsTableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: ContactsTableViewCell.identifier)
        self.setNavigationButton()
        
        try! self.fetchedResultsController.performFetch()
    }

    private func setNavigationButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addContact))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    //MARK: - User Actions
    private func searchContactsFor(_ query: String) {
        let request: NSFetchRequest = Contact.fetchRequest()
        let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", query)
        let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", query)
        request.predicate = NSCompoundPredicate(type: .or, subpredicates: [lastNamePredicate, firstNamePredicate])
        request.sortDescriptors = [self.sortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            
        }
    }
    
    @objc private func addContact() {
        self.show(AddContactViewController(), sender: self)
    }
    
    private func deleteContact(object: Contact, at indexPath: IndexPath) {
        ContactsDataManager().deleteNSManagedObject(object: object) { (error) in
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
        guard let objs = self.fetchedResultsController.fetchedObjects else { return 0 }
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
        let contact = self.fetchedResultsController.fetchedObjects?[indexPath.row]
        
        cell.nameLabel.text = contact?.fullName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = self.fetchedResultsController.object(at: indexPath)
            self.deleteContact(object: contact, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = self.fetchedResultsController.object(at: indexPath)
        self.show(ContactDetailViewController(contact: contact), sender: self)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.isFiltered = true
        self.searchContactsFor(text)
        searchBar.resignFirstResponder()
        self.contactsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isFiltered = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        if let defaultResultsController = self.defaultResultsController {
            self.fetchedResultsController = defaultResultsController
        }
        try! self.fetchedResultsController.performFetch()
        self.contactsTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.text = nil
            self.contactsTableView.reloadData()
        }
    }
}
