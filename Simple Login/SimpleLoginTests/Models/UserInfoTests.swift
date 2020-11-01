//
//  UserInfoTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class UserInfoTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: UserInfo!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "UserInfo")
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
    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["name"] as? String)
    }

    func testDecodeEmail() {
        XCTAssertEqual(sut.email, dictionary["email"] as? String)
    }

    func testDecodeProfilePictureUrl() {
        XCTAssertEqual(sut.profilePictureUrl, dictionary["profile_picture_url"] as? String)
    }

    func testDecodeIsPremium() {
        XCTAssertEqual(sut.isPremium, dictionary["is_premium"] as? Bool)
    }

    func testDecodeInTrial() {
        XCTAssertEqual(sut.inTrial, dictionary["in_trial"] as? Bool)
    }
}
