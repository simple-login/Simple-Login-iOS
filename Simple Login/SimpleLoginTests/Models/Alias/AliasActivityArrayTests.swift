//
//  AliasActivityArrayTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasActivityArrayTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: AliasActivityArray!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "AliasActivityArray")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeAliases() {
        XCTAssertEqual(sut.activities.count, 3)
    }
}
