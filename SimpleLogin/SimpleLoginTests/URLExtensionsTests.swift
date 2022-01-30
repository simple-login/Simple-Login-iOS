//
//  URLExtensionsTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

@testable import SimpleLogin
import XCTest

final class URLExtensionsTests: XCTestCase {
    func testExtractNotWwwHostName() throws {
        let url1 = try XCTUnwrap(URL(string: "https://www.example.com"))
        XCTAssertEqual(url1.notWwwHostname(), "example")
        let url2 = try XCTUnwrap(URL(string: "https://example.com"))
        XCTAssertEqual(url2.notWwwHostname(), "example")
    }
}
