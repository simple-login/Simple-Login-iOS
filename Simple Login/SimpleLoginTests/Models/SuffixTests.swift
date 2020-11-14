//
//  SuffixTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SuffixTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Suffix!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Suffix")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeValue() {
        XCTAssertEqual(sut.value, dictionary["suffix"] as? String)
    }

    func testDecodeSignature() {
        XCTAssertEqual(sut.signature, dictionary["signed_suffix"] as? String)
    }
}
