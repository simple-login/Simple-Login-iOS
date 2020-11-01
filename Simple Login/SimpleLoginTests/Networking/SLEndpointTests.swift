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

    func assertProperlyAttachedApiKey(_ urlRequest: URLRequest, apiKey: ApiKey) {
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authentication"], apiKey.value)
    }

    func assertProperlySetJsonContentType(_ urlRequest: URLRequest) {
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
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
        assertProperlySetJsonContentType(loginRequest)
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
        assertProperlyAttachedApiKey(userInfoRequest, apiKey: apiKey)
    }

    func testWithoutSearchTermCorrectlyGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let expectedUrl = baseUrl.componentsFor(path: "/api/v2/aliases",
                                                queryItems: [URLQueryItem(name: "page_id", value: "\(page)")]).url

        // when
        let aliasesEndpoint = SLEndpoint.aliases(baseUrl: baseUrl, apiKey: apiKey, page: page, searchTerm: nil)
        let aliasesRequest = try XCTUnwrap(aliasesEndpoint.urlRequest)

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(aliasesRequest, apiKey: apiKey)
        XCTAssertNil(aliasesRequest.allHTTPHeaderFields?["Content-Type"])
    }

    func testWithSearchTermCorrectlyGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let searchTerm = "john doe"
        let expectedHttpBody = try JSONEncoder().encode(["query": searchTerm])

        let expectedUrl = baseUrl.componentsFor(path: "/api/v2/aliases",
                                                queryItems: [URLQueryItem(name: "page_id", value: "\(page)")]).url

        // when
        let aliasesEndpoint = SLEndpoint.aliases(baseUrl: baseUrl,
                                                 apiKey: apiKey,
                                                 page: page,
                                                 searchTerm: searchTerm)
        let aliasesRequest = try XCTUnwrap(aliasesEndpoint.urlRequest)

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.post)
        assertProperlyAttachedApiKey(aliasesRequest, apiKey: apiKey)
        assertProperlySetJsonContentType(aliasesRequest)
        XCTAssertEqual(aliasesRequest.httpBody, expectedHttpBody)
    }

    func testCorrectlyGenerateAliasActivitiesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 2_769
        let page = 23

        let expectedUrl =
            baseUrl.componentsFor(path: "/api/aliases/\(aliasId)/activities",
                                  queryItems: [URLQueryItem(name: "page_id", value: "\(page)")]).url

        // when
        let aliasAtivitiesEndpoint = SLEndpoint.aliasActivities(baseUrl: baseUrl,
                                                                apiKey: apiKey,
                                                                aliasId: aliasId,
                                                                page: page)
        let aliasActivitiesRequest = try XCTUnwrap(aliasAtivitiesEndpoint.urlRequest)

        // then
        XCTAssertEqual(aliasActivitiesRequest.url, expectedUrl)
        XCTAssertEqual(aliasActivitiesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(aliasActivitiesRequest, apiKey: apiKey)
    }

    func testCorrectlyGenerateMailboxesRequest() throws {
        // given
        let apiKey = givenApiKey()

        let expectedUrl = baseUrl.componentsFor(path: "/api/mailboxes").url

        // when
        let mailboxesEndpoint = SLEndpoint.mailboxes(baseUrl: baseUrl, apiKey: apiKey)
        let mailboxesRequest = try XCTUnwrap(mailboxesEndpoint.urlRequest)

        // then
        XCTAssertEqual(mailboxesRequest.url, expectedUrl)
        XCTAssertEqual(mailboxesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(mailboxesRequest, apiKey: apiKey)
    }

    func testCorrectlyGenerateContactsRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 572
        let page = 10
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")

        let expectedUrl =
            baseUrl.componentsFor(path: "/api/aliases/\(aliasId)/contacts", queryItems: [queryItem]).url

        // when
        let contactsEndpoint = SLEndpoint.contacts(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)
        let contactsRequest = try XCTUnwrap(contactsEndpoint.urlRequest)

        // then
        XCTAssertEqual(contactsRequest.url, expectedUrl)
        XCTAssertEqual(contactsRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(contactsRequest, apiKey: apiKey)
    }
}
