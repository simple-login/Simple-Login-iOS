//
//  ContactTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ContactTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Contact!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Contact")
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
        XCTAssertEqual(sut.email, dictionary["contact"] as? String)
    }

    func testDecodeReverseAlias() {
        XCTAssertEqual(sut.reverseAlias, dictionary["reverse_alias"] as? String)
    }

    func testDecodeCreationDate() {
        XCTAssertEqual(sut.creationDate, dictionary["creation_date"] as? String)
    }

    func testDecodeCreationTimestamp() {
        XCTAssertEqual(sut.creationTimestamp, dictionary["creation_timestamp"] as? TimeInterval)
    }

    func testDecodeLastEmailSentDate() {
        XCTAssertEqual(sut.lastEmailSentDate, dictionary["last_email_send_date"] as? String)
    }

    func testDecodeLastEmailSentTimestamp() {
        XCTAssertEqual(sut.lastEmailSentTimestamp, dictionary["last_email_sent_timestamp"] as? TimeInterval)
    }
}
