//
//  OkTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 02/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class OkTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Ok!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Ok")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeOk() {
        XCTAssertEqual(sut.value, dictionary["ok"] as? Bool)
    }
}
