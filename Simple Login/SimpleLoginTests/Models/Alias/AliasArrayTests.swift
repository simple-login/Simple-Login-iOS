//
//  AliasArrayTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasArrayTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: AliasArray!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "AliasArray")
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
        XCTAssertEqual(sut.aliases.count, 3)
    }
}
