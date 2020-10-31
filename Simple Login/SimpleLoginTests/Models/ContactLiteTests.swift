//
//  ContactLiteTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ContactLiteTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: ContactLite!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "ContactLite")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeEmail() {
        XCTAssertEqual(sut.email, dictionary["email"] as? String)
    }

    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["name"] as? String)
    }

    func testDecodeReverseAlias() {
        XCTAssertEqual(sut.reverseAlias, dictionary["reverse_alias"] as? String)
    }
}
