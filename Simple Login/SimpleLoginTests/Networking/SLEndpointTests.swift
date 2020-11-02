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

    func testGenerateLoginRequest() throws {
        // given
        let expectedEmail = "john.doe@example.com"
        let expectedPassword =
            // swiftlint:disable:next line_length
            #"<[y9G'%8Z]rc}.}g/9-u(J'~v.#"["`M2N}"-@o;Rzz;F`[-}\b^sS9U/:H+nJzVe\nj6VG/F\u4"qJH'g$2d)6<3yH+%hrJ}nzL\cUc$D:MSTnNRx!-~jm`~=ZSpoc_"#
        let expectedDeviceName = "iphone"

        let expectedUrl = baseUrl.append(path: "/api/auth/login")

        // when
        let loginRequest = SLEndpoint.login(baseUrl: baseUrl,
                                            email: expectedEmail,
                                            password: expectedPassword,
                                            deviceName: expectedDeviceName).urlRequest

        let loginRequestHttpBody = try XCTUnwrap(loginRequest.httpBody)
        let loginRequestHttpBodyDict =
            try JSONSerialization.jsonObject(with: loginRequestHttpBody) as? [String: Any]

        // then
        XCTAssertEqual(loginRequest.url, expectedUrl)
        XCTAssertEqual(loginRequest.httpMethod, HTTPMethod.post)

        assertProperlySetJsonContentType(loginRequest)
        XCTAssertEqual(loginRequestHttpBodyDict?["email"] as? String, expectedEmail)
        XCTAssertEqual(loginRequestHttpBodyDict?["password"] as? String, expectedPassword)
        XCTAssertEqual(loginRequestHttpBodyDict?["device"] as? String, expectedDeviceName)
    }

    func testGenerateUserInfoRequest() throws {
        // given
        let apiKey = givenApiKey()
        let expectedUrl = baseUrl.append(path: "/api/user_info")

        // when
        let userInfoRequest = SLEndpoint.userInfo(baseUrl: baseUrl,
                                                  apiKey: apiKey).urlRequest

        // then
        XCTAssertEqual(userInfoRequest.url, expectedUrl)
        XCTAssertEqual(userInfoRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(userInfoRequest, apiKey: apiKey)
    }

    func testWithoutSearchTermGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let expectedUrl = baseUrl.append(path: "/api/v2/aliases",
                                         queryItems: [queryItem])

        // when
        let aliasesRequest = SLEndpoint.aliases(baseUrl: baseUrl,
                                                apiKey: apiKey,
                                                page: page,
                                                searchTerm: nil).urlRequest

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(aliasesRequest, apiKey: apiKey)
        XCTAssertNil(aliasesRequest.allHTTPHeaderFields?["Content-Type"])
    }

    func testWithSearchTermGenerateAliasesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let page = 25
        let searchTerm = "john doe"
        let expectedHttpBody = try JSONEncoder().encode(["query": searchTerm])

        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let expectedUrl = baseUrl.append(path: "/api/v2/aliases",
                                         queryItems: [queryItem])

        // when
        let aliasesRequest = SLEndpoint.aliases(baseUrl: baseUrl,
                                                apiKey: apiKey,
                                                page: page,
                                                searchTerm: searchTerm).urlRequest

        // then
        XCTAssertEqual(aliasesRequest.url, expectedUrl)
        XCTAssertEqual(aliasesRequest.httpMethod, HTTPMethod.post)
        assertProperlyAttachedApiKey(aliasesRequest, apiKey: apiKey)
        assertProperlySetJsonContentType(aliasesRequest)
        XCTAssertEqual(aliasesRequest.httpBody, expectedHttpBody)
    }

    func testGenerateAliasActivitiesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 2_769
        let page = 23

        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let expectedUrl =
            baseUrl.append(path: "/api/aliases/\(aliasId)/activities",
                           queryItems: [queryItem])

        // when
        let aliasActivitiesRequest = SLEndpoint.aliasActivities(baseUrl: baseUrl,
                                                                apiKey: apiKey,
                                                                aliasId: aliasId,
                                                                page: page).urlRequest

        // then
        XCTAssertEqual(aliasActivitiesRequest.url, expectedUrl)
        XCTAssertEqual(aliasActivitiesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(aliasActivitiesRequest, apiKey: apiKey)
    }

    func testGenerateMailboxesRequest() throws {
        // given
        let apiKey = givenApiKey()

        let expectedUrl = baseUrl.append(path: "/api/mailboxes")

        // when
        let mailboxesRequest = SLEndpoint.mailboxes(baseUrl: baseUrl,
                                                    apiKey: apiKey).urlRequest

        // then
        XCTAssertEqual(mailboxesRequest.url, expectedUrl)
        XCTAssertEqual(mailboxesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(mailboxesRequest, apiKey: apiKey)
    }

    func testGenerateContactsRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 572
        let page = 10
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")

        let expectedUrl =
            baseUrl.append(path: "/api/aliases/\(aliasId)/contacts",
                           queryItems: [queryItem])

        // when
        let contactsRequest = SLEndpoint.contacts(baseUrl: baseUrl,
                                                  apiKey: apiKey,
                                                  aliasId: aliasId,
                                                  page: page).urlRequest

        // then
        XCTAssertEqual(contactsRequest.url, expectedUrl)
        XCTAssertEqual(contactsRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(contactsRequest, apiKey: apiKey)
    }

    func testGenerateUpdateAliasMailboxesRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 244

        let mailboxIds = [123, 4_219, 12]
        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["mailbox_ids": mailboxIds])

        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let updateAliasMailboxesRequest =
            SLEndpoint.updateAliasMailboxes(baseUrl: baseUrl,
                                            apiKey: apiKey,
                                            aliasId: aliasId,
                                            mailboxIds: mailboxIds).urlRequest

        // then
        XCTAssertEqual(updateAliasMailboxesRequest.url, expectedUrl)
        XCTAssertEqual(updateAliasMailboxesRequest.httpMethod, HTTPMethod.put)
        XCTAssertEqual(updateAliasMailboxesRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(updateAliasMailboxesRequest)
        assertProperlyAttachedApiKey(updateAliasMailboxesRequest, apiKey: apiKey)
    }

    func testGenerateUpdateAliasNameRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 789
        let name = "John Doe"

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["name": name])
        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let updateAliasNameRequest =
            SLEndpoint.updateAliasName(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, name: name).urlRequest

        // then
        XCTAssertEqual(updateAliasNameRequest.url, expectedUrl)
        XCTAssertEqual(updateAliasNameRequest.httpMethod, HTTPMethod.put)
        XCTAssertEqual(updateAliasNameRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(updateAliasNameRequest)
        assertProperlyAttachedApiKey(updateAliasNameRequest, apiKey: apiKey)
    }

    func testGenerateUpdateAliasNoteRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 637
        let note = "some note"

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["note": note])
        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let updateAliasNameRequest =
            SLEndpoint.updateAliasNote(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, note: note).urlRequest

        // then
        XCTAssertEqual(updateAliasNameRequest.url, expectedUrl)
        XCTAssertEqual(updateAliasNameRequest.httpMethod, HTTPMethod.put)
        XCTAssertEqual(updateAliasNameRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(updateAliasNameRequest)
        assertProperlyAttachedApiKey(updateAliasNameRequest, apiKey: apiKey)
    }

    func testGenerateRandomAliasRequest() throws {
        // given
        let apiKey = givenApiKey()
        let randomMode = RandomMode.word

        let queryItem = URLQueryItem(name: "mode", value: randomMode.rawValue)
        let expectedUrl = baseUrl.append(path: "/api/alias/random/new", queryItems: [queryItem])

        // when
        let randomAliasRequest =
            SLEndpoint.randomAlias(baseUrl: baseUrl, apiKey: apiKey, randomMode: randomMode).urlRequest

        // then
        XCTAssertEqual(randomAliasRequest.url, expectedUrl)
        XCTAssertEqual(randomAliasRequest.httpMethod, HTTPMethod.post)
        assertProperlyAttachedApiKey(randomAliasRequest, apiKey: apiKey)
    }

    func testGenerateToggleAliasRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 1_383

        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)/toggle")

        // when
        let toggleAliasRequest =
            SLEndpoint.toggleAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId).urlRequest

        // then
        XCTAssertEqual(toggleAliasRequest.url, expectedUrl)
        XCTAssertEqual(toggleAliasRequest.httpMethod, HTTPMethod.post)
        assertProperlyAttachedApiKey(toggleAliasRequest, apiKey: apiKey)
    }

    func testGenerateDeleteAliasRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 879

        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let deleteAliasRequest =
            SLEndpoint.deleteAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId).urlRequest

        // then
        XCTAssertEqual(deleteAliasRequest.url, expectedUrl)
        XCTAssertEqual(deleteAliasRequest.httpMethod, HTTPMethod.delete)
        assertProperlyAttachedApiKey(deleteAliasRequest, apiKey: apiKey)
    }

    func testGenerateGetAliasRequest() throws {
        // given
        let apiKey = givenApiKey()
        let aliasId = 612

        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let getAliasRequest = SLEndpoint.getAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId).urlRequest

        // then
        XCTAssertEqual(getAliasRequest.url, expectedUrl)
        XCTAssertEqual(getAliasRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(getAliasRequest, apiKey: apiKey)
    }
}
