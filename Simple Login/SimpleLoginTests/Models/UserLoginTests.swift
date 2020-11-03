//
//  UserLoginTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class UserLoginTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: UserLogin!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "UserLogin")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    // MARK: - Decodable test
    func testDecodeApiKey() {
        XCTAssertEqual(sut.apiKey?.value, dictionary["api_key"] as? String)
    }

    func testDecodeEmail() {
        XCTAssertEqual(sut.email, dictionary["email"] as? String)
    }

    func testDecodeIsMfaEnabled() {
        XCTAssertEqual(sut.isMfaEnabled, dictionary["mfa_enabled"] as? Bool)
    }

    func testDecodeMfaKey() {
        XCTAssertEqual(sut.mfaKey, dictionary["mfa_key"] as? String)
    }

    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["name"] as? String)
    }
}
