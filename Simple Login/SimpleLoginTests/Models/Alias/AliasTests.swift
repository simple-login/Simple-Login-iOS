//
//  AliasTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Alias!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Alias")
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

    func testDecodeCreationDate() {
        XCTAssertEqual(sut.creationDate, dictionary["creation_date"] as? String)
    }

    func testDecodeCreationTimestamp() {
        XCTAssertEqual(sut.creationTimestamp, dictionary["creation_timestamp"] as? TimeInterval)
    }

    func testDecodeBlockCount() {
        XCTAssertEqual(sut.blockCount, dictionary["nb_block"] as? Int)
    }

    func testDecodeReplyCount() {
        XCTAssertEqual(sut.replyCount, dictionary["nb_reply"] as? Int)
    }

    func testDecodeForwardCount() {
        XCTAssertEqual(sut.forwardCount, dictionary["nb_forward"] as? Int)
    }

    func testDecodeLatestActivity() throws {
        let latestActivityDict = dictionary["latest_activity"] as? [String: Any]
        let contactDict = latestActivityDict?["contact"] as? [String: String?]
        let contactData = try JSONEncoder().encode(contactDict)
        let expectedContact = try JSONDecoder().decode(ContactLite.self, from: contactData)

        XCTAssertEqual(sut.latestActivity?.action.rawValue, latestActivityDict?["action"] as? String)
        XCTAssertEqual(sut.latestActivity?.contact, expectedContact)
        XCTAssertEqual(sut.latestActivity?.timestamp, latestActivityDict?["timestamp"] as? TimeInterval)
    }

    func testDecodeIsPgpSupported() {
        XCTAssertEqual(sut.isPgpSupported, dictionary["support_pgp"] as? Bool)
    }

    func testDecodeIsPgpDisabled() {
        XCTAssertEqual(sut.isPgpDisabled, dictionary["disable_pgp"] as? Bool)
    }

    func testDecodeMailboxes() {
        XCTAssertEqual(sut.mailboxes.count, 2)
    }

    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["name"] as? String)
    }

    func testDecodeNote() {
        XCTAssertEqual(sut.note, dictionary["note"] as? String)
    }

    func testDecodeEnabled() {
        XCTAssertEqual(sut.enabled, dictionary["enabled"] as? Bool)
    }
}
