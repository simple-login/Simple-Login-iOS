//
//  LatestActivityTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class LatestActivityTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: LatestActivity!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "LatestActivity")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeAction() {
        XCTAssertEqual(sut.action.rawValue, dictionary["action"] as? String)
    }

    func testDecodeContact() {
        let contactDict = dictionary["contact"] as? [String: Any]
        let expectedEmail = contactDict?["email"] as? String
        let expectedName = contactDict?["name"] as? String
        let expectedReverseAlias = contactDict?["reverse_alias"] as? String

        XCTAssertEqual(sut.contact.email, expectedEmail)
        XCTAssertEqual(sut.contact.name, expectedName)
        XCTAssertEqual(sut.contact.reverseAlias, expectedReverseAlias)
    }

    func testDecodeTimestamp() {
        XCTAssertEqual(sut.timestamp, dictionary["timestamp"] as? TimeInterval)
    }
}
