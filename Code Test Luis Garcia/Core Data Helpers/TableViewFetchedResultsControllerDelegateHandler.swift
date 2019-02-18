//
//  TableViewFetchedResultsControllerDelegateHandler.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 2/17/19.
//  Copyright © 2019 Luis Garcia. All rights reserved.
//

import UIKit
import CoreData

class TableViewFetchedResultsControllerDelegateHandler: NSObject {
    private let tableView: UITableView
    
    fileprivate var insertionChanges = [IndexPath]()
    fileprivate var updateChanges = [IndexPath]()
    fileprivate var moveChanges = [[IndexPath]]()
    fileprivate var deleteChanges = [IndexPath]()
    
    //MARK: - Init
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
    }
}

extension TableViewFetchedResultsControllerDelegateHandler: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertionChanges.removeAll()
        deleteChanges.removeAll()
        moveChanges.removeAll()
        updateChanges.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.performBatchUpdates({
            if insertionChanges.count > 0 {
                tableView.insertRows(at: insertionChanges, with: .automatic)
            }
            
            if deleteChanges.count > 0 {
                tableView.deleteRows(at: deleteChanges, with: .fade)
            }
            
            if moveChanges.count > 0 {
                for indexPaths in moveChanges {
                    tableView.moveRow(at: indexPaths[0], to: indexPaths[1])
                }
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertionChanges.append(newIndexPath!)
        case .delete:
            deleteChanges.append(indexPath!)
        case .move:
            moveChanges.append([indexPath!, newIndexPath!])
        case .update:
            updateChanges.append(indexPath!)
        }
    }
}
