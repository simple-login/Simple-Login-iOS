//
//  AliasMailboxTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasMailboxTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: AliasMailbox!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "AliasMailbox")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeId() {
        XCTAssertEqual(sut.id, dictionary["id"] as? Int)
    }

    func testDecodeEmail() {
        XCTAssertEqual(sut.email, dictionary["email"] as? String)
    }

    func testInit() {
        // given
        let expectedId = 290
        let expectedEmail = "john.doe@example.com"

        // when
        let aliasMailbox = AliasMailbox(id: expectedId, email: expectedEmail)

        // then
        XCTAssertEqual(aliasMailbox.id, expectedId)
        XCTAssertEqual(aliasMailbox.email, expectedEmail)
    }

    func testComparable() {
        let smallerAliasMailbox = AliasMailbox(id: 1_000, email: "jane.doe@example.com")
        let biggerAliasMailbox = AliasMailbox(id: 999, email: "john.doe@example.com")

        XCTAssertTrue(smallerAliasMailbox < biggerAliasMailbox)
    }
}
