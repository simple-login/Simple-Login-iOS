//
//  ContactArrayTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ContactArrayTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: ContactArray!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "ContactArray")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeContacts() {
        XCTAssertEqual(sut.contacts.count, 3)
    }
}
