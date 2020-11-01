//
//  MailboxArrayTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class MailboxArrayTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: MailboxArray!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "MailboxArray")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeMailboxes() {
        XCTAssertEqual(sut.mailboxes.count, 3)
    }
}
