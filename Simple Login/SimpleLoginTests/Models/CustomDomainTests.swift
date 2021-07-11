//
//  CustomDomainTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 03/03/2021.
//  Copyright © 2021 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class CustomDomainTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: CustomDomain!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "CustomDomain")
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

    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["domain"] as? String)
    }

    func testDecodeAliasCount() {
        XCTAssertEqual(sut.aliasCount, dictionary["nb_alias"] as? Int)
    }

    func testDecodeIsVerified() {
        XCTAssertEqual(sut.isVerified, dictionary["verified"] as? Bool)
    }
}
