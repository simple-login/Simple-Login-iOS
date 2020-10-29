//
//  SLClientTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientTests: XCTestCase {
    func testInitWithDefaultArgs() throws {
        // given
        let expectedNetworkEngine = URLSession.shared
        let expectedBaseUrl = try XCTUnwrap(URL(string: kDefaultBaseUrlString))

        // when
        let sut = try XCTUnwrap(SLClient())
        let networkEngine = try XCTUnwrap(sut.engine as? URLSession)

        // then
        XCTAssertEqual(networkEngine, expectedNetworkEngine)
        XCTAssertEqual(sut.baseUrl, expectedBaseUrl)
    }

    func testInitWithBadUrlStringThrowsBadUrlStringError() throws {
        // given
        let badUrlString = "bad url string"
        let expectedError = SLError.badUrlString(urlString: badUrlString)

        // when
        var storedError: SLError?

        do {
            _ = try SLClient(baseUrlString: badUrlString)
        } catch {
            storedError = error as? SLError
        }

        // then
        XCTAssertEqual(storedError, expectedError)
    }

    func testInitWithValidUrlString() throws {
        // given
        let validUrlString = "https://example.com"
        let expectedUrl = try XCTUnwrap(URL(string: validUrlString))

        // when
        let sut = try SLClient(baseUrlString: validUrlString)

        // then
        XCTAssertEqual(sut.baseUrl, expectedUrl)
    }
}
