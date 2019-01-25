//
//  CoreDataManagerTests.swift
//  Code Test Luis Garcia Tests
//
//  Created by Luis Garcia on 1/24/19.
//  Copyright © 2019 Luis Garcia. All rights reserved.
//

import XCTest
import CoreData
@testable import Code_Test_Luis_Garcia

class CoreDataManagerTests: XCTestCase {

    var sut: ContactsDataManager!
    var coreDataStack: CoreDataTestsStack!
    
    override func setUp() {
        coreDataStack = CoreDataTestsStack()
        sut = ContactsDataManager(backgroundContext: coreDataStack.backgroundContext)
    }

    func test_init_contexts() {
        XCTAssertEqual(sut.backgroundContext, coreDataStack.backgroundContext)
    }
    
    func test_CreateContact() {
        
        let firstName = "Ramon"
        let lastName = "Cuard"
        let dob = Date(timeIntervalSince1970: 200000)
        
        sut.saveContact(firstName: firstName, lastName: lastName, dob: dob) { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertEqual(contact!.firstName, "Ramon")
            XCTAssertEqual(contact!.lastName, "Cuard")
            XCTAssertEqual(contact!.dob, NSDate(timeIntervalSince1970: 200000))
        }
    }
    
    func testAddPhoneToContact() {
        
        let firstName = "Ramon"
        let lastName = "Cuard"
        let dob = Date(timeIntervalSince1970: 200000)
        
        sut.saveContact(firstName: firstName, lastName: lastName, dob: dob) { (contact, error) in
            XCTAssertNotNil(contact)
            self.sut.addPhoneTo(contact: contact!, number: "9998887777", type: "home", completion: { (contact, error) in
                XCTAssertNotNil(contact)
                XCTAssertNotNil(contact?.phone.allObjects.first)
                let phoneObject = contact!.phone.allObjects.first as! Phone
                XCTAssertEqual(phoneObject.number, "9998887777")
                XCTAssertEqual(phoneObject.type, "home")
            })
        }
    }
    
    override func tearDown() {
        self.coreDataStack.persistentContainer.destroyPersistentStore()
    }

}
