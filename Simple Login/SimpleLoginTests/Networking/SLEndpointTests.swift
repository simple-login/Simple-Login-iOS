//
//  SLEndpointTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLEndpointTests: XCTestCase {
    private let scheme = "https"
    private let host = "example.com"

    var baseUrl: URL!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_unwrapping
        baseUrl = URL(string: "\(scheme)://\(host)")!
    }

    override func tearDown() {
        baseUrl = nil
        super.tearDown()
    }

    func givenApiKey() -> ApiKey {
        ApiKey(value: "an api key")
    }

    func testCorrectlyGenerateLoginRequest() throws {
        // given
        let email = "john.doe@example.com"
        let password = "johndoe"
        let deviceName = "iphone"

        let expectedHttpBody = try JSONEncoder().encode(["email": email,
                                                         "password": password,
                                                         "device": deviceName])

        let expectedUrl = baseUrl.componentsFor(path: "/api/auth/login").url

        // when
        let loginEndpoint = SLEndpoint.login(baseUrl: baseUrl,
                                             email: email,
                                             password: password,
                                             deviceName: deviceName)
        let loginRequest = try XCTUnwrap(loginEndpoint.urlRequest)

        // then
        XCTAssertEqual(loginRequest.url, expectedUrl)
        XCTAssertEqual(loginRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(loginRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(loginRequest.httpBody, expectedHttpBody)
    }

    func testCorrectlyGenerateUserInfoRequest() throws {
        // given
        let apiKey = givenApiKey()
        let expectedUrl = baseUrl.componentsFor(path: "/api/user_info").url

        // when
        let userInfoEndpoint = SLEndpoint.userInfo(baseUrl: baseUrl, apiKey: apiKey)
        let userInfoRequest = try XCTUnwrap(userInfoEndpoint.urlRequest)

        // then
        XCTAssertEqual(userInfoRequest.url, expectedUrl)
        XCTAssertEqual(userInfoRequest.httpMethod, HTTPMethod.get)
        XCTAssertEqual(userInfoRequest.allHTTPHeaderFields?["Authentication"], apiKey.value)
    }

    func testWithoutSearchTermCorrectlyGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let expectedUrl = baseUrl.componentsFor(path: "/api/v2/aliases?page_id=\(page)").url

        // when
        let aliasesEndpoint = SLEndpoint.aliases(baseUrl: baseUrl, apiKey: apiKey, page: page, searchTerm: nil)
        let aliasesRequest = try XCTUnwrap(aliasesEndpoint.urlRequest)

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.get)
        XCTAssertEqual(aliasesRequest.allHTTPHeaderFields?["Authentication"], apiKey.value)
        XCTAssertNil(aliasesRequest.allHTTPHeaderFields?["Content-Type"])
    }

    func testWithSearchTermCorrectlyGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let searchTerm = "john doe"
        let expectedHttpBody = try JSONEncoder().encode(["query": searchTerm])

        let expectedUrl = baseUrl.componentsFor(path: "/api/v2/aliases?page_id=\(page)").url

        // when
        let aliasesEndpoint = SLEndpoint.aliases(baseUrl: baseUrl,
                                                 apiKey: apiKey,
                                                 page: page,
                                                 searchTerm: searchTerm)
        let aliasesRequest = try XCTUnwrap(aliasesEndpoint.urlRequest)

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(aliasesRequest.allHTTPHeaderFields?["Authentication"], apiKey.value)
        XCTAssertEqual(aliasesRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(aliasesRequest.httpBody, expectedHttpBody)
    }
}
