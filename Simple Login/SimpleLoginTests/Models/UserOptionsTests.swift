//
//  UserOptionTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 04/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class UserOptionsTest: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: UserOptions!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "UserOptions")
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
    func testDecodeCanCreate() {
        XCTAssertEqual(sut.canCreate, dictionary["can_create"] as? Bool)
    }

    func testDecodePrefixSuggestion() {
        XCTAssertEqual(sut.prefixSuggestion, dictionary["prefix_suggestion"] as? String)
    }

    func testDecodeSuffixes() throws {
        // given
        let suffixesArray = try XCTUnwrap(dictionary["suffixes"] as? [[String]])
        let expectedFirstSuffix = Suffix(value: suffixesArray[0])
        let expectedSecondSuffix = Suffix(value: suffixesArray[1])
        let expectedThirdSuffix = Suffix(value: suffixesArray[2])

        // when
        let firstSuffix = try XCTUnwrap(sut.suffixes[0])
        let secondSuffix = try XCTUnwrap(sut.suffixes[1])
        let thirdSuffix = try XCTUnwrap(sut.suffixes[2])

        // then
        XCTAssertEqual(firstSuffix, expectedFirstSuffix)
        XCTAssertEqual(secondSuffix, expectedSecondSuffix)
        XCTAssertEqual(thirdSuffix, expectedThirdSuffix)
    }
}
