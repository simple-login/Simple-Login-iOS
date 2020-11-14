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
        let suffixesArray = try XCTUnwrap(dictionary["suffixes"] as? [[String: String]])

        let expectedFirstSuffix =
            try Suffix(value: XCTUnwrap(suffixesArray[0]["suffix"]),
                       signature: XCTUnwrap(suffixesArray[0]["signed_suffix"]))

        let expectedSecondSuffix =
            try Suffix(value: XCTUnwrap(suffixesArray[1]["suffix"]),
                       signature: XCTUnwrap(suffixesArray[1]["signed_suffix"]))

        let expectedThirdSuffix =
            try Suffix(value: XCTUnwrap(suffixesArray[2]["suffix"]),
                       signature: XCTUnwrap(suffixesArray[2]["signed_suffix"]))

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
