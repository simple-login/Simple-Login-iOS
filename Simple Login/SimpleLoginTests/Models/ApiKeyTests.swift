//
//  ApiKeyTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ApiKeyTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: ApiKey!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "ApiKey")
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeValue() {
        XCTAssertEqual(sut.value, dictionary["api_key"] as? String)
    }

    func testInitValue() {
        // given
        let expectedApiKeyValue = "a random string"

        // when
        let apiKey = ApiKey(value: expectedApiKeyValue)

        // then
        XCTAssertEqual(apiKey.value, expectedApiKeyValue)
    }
}
