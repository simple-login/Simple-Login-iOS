//
//  StringExtensionsTests.swift
//  SimpleLoginTests
//
//  Created by Nhon Nguyen on 13/05/2022.
//

@testable import SimpleLogin
import XCTest

final class StringExtensionsTests: XCTestCase {
    func testExtractFirstUrl() throws {
        let string = "This string contains no url"
        XCTAssertNil(string.firstUrl())

        let string1 = "One url https://example.com"
        XCTAssertEqual(string1.firstUrl()?.absoluteString, "https://example.com")

        let string2 = "One url https://ExAmple.com"
        XCTAssertEqual(string2.firstUrl()?.absoluteString, "https://example.com")

        let string3 = "Two urls https://test.com and https://example.com"
        XCTAssertEqual(string3.firstUrl()?.absoluteString, "https://test.com")
    }
}
