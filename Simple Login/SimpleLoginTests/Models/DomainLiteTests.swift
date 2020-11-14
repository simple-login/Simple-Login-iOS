//
//  DomainLiteTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class DomainLiteTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: DomainLite!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "DomainLite")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeName() {
        XCTAssertEqual(sut.name, dictionary["domain"] as? String)
    }

    func testDecodeIsCustom() {
        XCTAssertEqual(sut.isCustom, dictionary["is_custom"] as? Bool)
    }
}
