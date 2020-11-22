//
//  UserSettingsTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 13/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class UserSettingsTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: UserSettings!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "UserSettings")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    // MARK: Decodable tests
    func testDecodeRandomMode() throws {
        let aliasGenerator = try XCTUnwrap(dictionary["alias_generator"] as? String)
        let expectedRandomMode = try XCTUnwrap(RandomMode(rawValue: aliasGenerator))
        XCTAssertEqual(sut.randomMode, expectedRandomMode)
    }

    func testDecodeNotification() {
        XCTAssertEqual(sut.notification, dictionary["notification"] as? Bool)
    }

    func testDecodeRandomAliasDefaultDomain() {
        XCTAssertEqual(sut.randomAliasDefaultDomain, dictionary["random_alias_default_domain"] as? String)
    }

    func testDecodeSenderFormat() throws {
        let senderFormatRawValue = try XCTUnwrap(dictionary["sender_format"] as? String)
        let expectedSenderFormat = try XCTUnwrap(SenderFormat(rawValue: senderFormatRawValue))
        XCTAssertEqual(sut.senderFormat, expectedSenderFormat)
    }
}
