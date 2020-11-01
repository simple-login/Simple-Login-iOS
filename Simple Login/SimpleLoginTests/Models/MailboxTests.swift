//
//  MailboxTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class MailboxTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Mailbox!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Mailbox")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    // MARK: - Decodable tests
    func testDecodeId() {
        XCTAssertEqual(sut.id, dictionary["id"] as? Int)
    }

    func testDecodeEmail() {
        XCTAssertEqual(sut.email, dictionary["email"] as? String)
    }

    func testDecodeIsDefault() {
        XCTAssertEqual(sut.isDefault, dictionary["default"] as? Bool)
    }

    func testDecodeNumOfAlias() {
        XCTAssertEqual(sut.numOfAlias, dictionary["nb_alias"] as? Int)
    }

    func testDecodeCreationTimestamp() {
        XCTAssertEqual(sut.creationTimestamp, dictionary["creation_timestamp"] as? TimeInterval)
    }

    // MARK: - Functionality tests
    func testChangeIsDefault() {
        let expectedIsDefault = !sut.isDefault
        sut.setIsDefault(expectedIsDefault)
        XCTAssertEqual(sut.isDefault, expectedIsDefault)
    }

    func testToAliasMailbox() {
        let expectedAliasMailbox = AliasMailbox(id: sut.id, email: sut.email)
        XCTAssertEqual(sut.toAliasMailbox(), expectedAliasMailbox)
    }
}
