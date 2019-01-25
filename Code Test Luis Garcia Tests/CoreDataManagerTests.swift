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
    var localContact = Contact()
    
    override func setUp() {
        coreDataStack = CoreDataTestsStack()
        sut = ContactsDataManager(backgroundContext: coreDataStack.backgroundContext)
        
        let firstName = "Ramon"
        let lastName = "Cuard"
        let dob = Date(timeIntervalSince1970: 200000)
        
        sut.saveContact(firstName: firstName, lastName: lastName, dob: dob) { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertEqual(contact!.firstName, "Ramon")
            XCTAssertEqual(contact!.lastName, "Cuard")
            XCTAssertEqual(contact!.dob, NSDate(timeIntervalSince1970: 200000))
            self.localContact = contact!
        }
    }
    
    func test_init_contexts() {
        XCTAssertEqual(sut.backgroundContext, coreDataStack.backgroundContext)
    }
    
    func test_CreateContact() {
        let firstName = "Jason"
        let lastName = "Bourne"
        let dob = Date(timeIntervalSince1970: 200000)

        sut.saveContact(firstName: firstName, lastName: lastName, dob: dob) { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertEqual(contact!.firstName, "Jason")
            XCTAssertEqual(contact!.lastName, "Bourne")
            XCTAssertEqual(contact!.dob, NSDate(timeIntervalSince1970: 200000))
            self.localContact = contact!
        }
    }
    
    func testAddPhoneToContact() {
        self.sut.addPhoneTo(contact: self.localContact, number: "9998887777", type: "home", completion: { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertNotNil(contact?.phone.allObjects.first)
            let phoneObject = contact!.phone.allObjects.first as! Phone
            XCTAssertEqual(phoneObject.number, "9998887777")
            XCTAssertEqual(phoneObject.type, "home")
        })
    }
    
    func testAddEmailToContact() {
        sut.addEmailTo(contact: self.localContact, address: "myemail@email.com", type: "home") { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertNotNil(contact?.email.allObjects.first)
            let addressObject = contact?.email.allObjects.first as! Email
            XCTAssertEqual(addressObject.address, "myemail@email.com")
            XCTAssertEqual(addressObject.type, "home")
            
        }
    }
    
    func testAddAddressToContact() {
        sut.addAddressTo(contact: self.localContact, street: "ABC 123 St.", streetDetail: nil, city: "Seaside", state: "AZ", zip: "12398", type: "home") { (contact, error) in
            XCTAssertNotNil(contact)
            XCTAssertNotNil(contact?.address.allObjects.first)
            let addressObject = contact!.address.allObjects.first as! Address
            XCTAssertEqual(addressObject.street, "ABC 123 St.")
            XCTAssertEqual(addressObject.city, "Seaside")
            XCTAssertEqual(addressObject.state, "AZ")
            XCTAssertEqual(addressObject.zip, "12398")
            XCTAssertEqual(addressObject.type, "home")
        }
    }
    
    override func tearDown() {
        sut.deleteNSManagedObject(object: self.localContact) { (error) in
            XCTAssertNil(error)
        }
        self.coreDataStack.persistentContainer.destroyPersistentStore()
    }

}
