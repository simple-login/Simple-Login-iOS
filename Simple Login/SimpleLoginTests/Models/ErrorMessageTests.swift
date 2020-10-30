//
//  ErrorMessageTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ErrorMessageTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: ErrorMessage!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "ErrorMessage")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeError() {
        XCTAssertEqual(sut.value, dictionary["error"] as? String)
    }
}
