//
//  SLEndpointTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

// swiftlint:disable type_body_length
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

    func assertProperlyAttachedApiKey(_ urlRequest: URLRequest, apiKey: ApiKey) {
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authentication"], apiKey.value)
    }

    func assertProperlySetJsonContentType(_ urlRequest: URLRequest) {
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func testGenerateLoginRequest() throws {
        // given
        let expectedEmail = String.randomEmail()
        let expectedPassword =
            // swiftlint:disable:next line_length
            #"<[y9G'%8Z]rc}.}g/9-u(J'~v.#"["`M2N}"-@o;Rzz;F`[-}\b^sS9U/:H+nJzVe\nj6VG/F\u4"qJH'g$2d)6<3yH+%hrJ}nzL\cUc$D:MSTnNRx!-~jm`~=ZSpoc_"#
        let expectedDeviceName = String.randomDeviceName()

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
        let apiKey = ApiKey.random()
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
        let apiKey = ApiKey.random()
        let page = Int.randomPageId()
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
        let apiKey = ApiKey.random()
        let page = Int.randomPageId()
        let searchTerm = String.randomName()
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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()
        let page = Int.randomPageId()

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
        let apiKey = ApiKey.random()

        let expectedUrl = baseUrl.append(path: "/api/v2/mailboxes")

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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()
        let page = Int.randomPageId()
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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()

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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()
        let name = String.randomName()

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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()
        let note = String.randomName()

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
        let apiKey = ApiKey.random()
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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()

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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()

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
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()

        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)")

        // when
        let getAliasRequest = SLEndpoint.getAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId).urlRequest

        // then
        XCTAssertEqual(getAliasRequest.url, expectedUrl)
        XCTAssertEqual(getAliasRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(getAliasRequest, apiKey: apiKey)
    }

    func testGenerateCreateContactRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let aliasId = Int.randomIdentifer()
        let email = String.randomEmail()

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["contact": email])
        let expectedUrl = baseUrl.append(path: "/api/aliases/\(aliasId)/contacts")

        // when
        let createContactRequest =
            SLEndpoint.createContact(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, email: email).urlRequest

        // then
        XCTAssertEqual(createContactRequest.url, expectedUrl)
        XCTAssertEqual(createContactRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(createContactRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(createContactRequest)
        assertProperlyAttachedApiKey(createContactRequest, apiKey: apiKey)
    }

    func testGenerateDeleteContactRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let contactId = Int.randomIdentifer()

        let expectedUrl = baseUrl.append(path: "/api/contacts/\(contactId)")

        // when
        let deleteContactRequest =
            SLEndpoint.deleteContact(baseUrl: baseUrl, apiKey: apiKey, contactId: contactId).urlRequest

        // then
        XCTAssertEqual(deleteContactRequest.url, expectedUrl)
        XCTAssertEqual(deleteContactRequest.httpMethod, HTTPMethod.delete)
        assertProperlyAttachedApiKey(deleteContactRequest, apiKey: apiKey)
    }

    func testGenerateCreateMailboxRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let email = String.randomEmail()

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["email": email])
        let expectedUrl = baseUrl.append(path: "/api/mailboxes")

        // when
        let createMailboxRequest =
            SLEndpoint.createMailbox(baseUrl: baseUrl, apiKey: apiKey, email: email).urlRequest

        // then
        XCTAssertEqual(createMailboxRequest.url, expectedUrl)
        XCTAssertEqual(createMailboxRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(createMailboxRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(createMailboxRequest)
        assertProperlyAttachedApiKey(createMailboxRequest, apiKey: apiKey)
    }

    func testGenerateDeleteMailboxRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let mailboxId = Int.randomIdentifer()

        let expectedUrl = baseUrl.append(path: "/api/mailboxes/\(mailboxId)")

        // when
        let deleteMailboxRequest =
            SLEndpoint.deleteMailbox(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId).urlRequest

        // then
        XCTAssertEqual(deleteMailboxRequest.url, expectedUrl)
        XCTAssertEqual(deleteMailboxRequest.httpMethod, HTTPMethod.delete)
        assertProperlyAttachedApiKey(deleteMailboxRequest, apiKey: apiKey)
    }

    func testGenerateMakeDefaultMailboxRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let mailboxId = Int.randomIdentifer()

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["default": true])
        let expectedUrl = baseUrl.append(path: "/api/mailboxes/\(mailboxId)")

        // when
        let makeDefaultMailboxRequest =
            SLEndpoint.makeDefaultMailbox(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId).urlRequest

        // then
        XCTAssertEqual(makeDefaultMailboxRequest.url, expectedUrl)
        XCTAssertEqual(makeDefaultMailboxRequest.httpMethod, HTTPMethod.put)
        XCTAssertEqual(makeDefaultMailboxRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(makeDefaultMailboxRequest)
        assertProperlyAttachedApiKey(makeDefaultMailboxRequest, apiKey: apiKey)
    }

    func testGenerateProcessPaymentRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let receiptData = String.randomPassword()

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["receipt_data": receiptData])
        let expectedUrl = baseUrl.append(path: "/api/apple/process_payment")

        // when
        let processPaymentRequest =
            SLEndpoint.processPayment(baseUrl: baseUrl, apiKey: apiKey, receiptData: receiptData).urlRequest

        // then
        XCTAssertEqual(processPaymentRequest.url, expectedUrl)
        XCTAssertEqual(processPaymentRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(processPaymentRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(processPaymentRequest)
        assertProperlyAttachedApiKey(processPaymentRequest, apiKey: apiKey)
    }

    func testGenerateForgotPasswordRequest() throws {
        // given
        let email = String.randomEmail()
        let expectedHttpBody =
            try JSONSerialization.data(withJSONObject: ["email": email])
        let expectedUrl = baseUrl.append(path: "/api/auth/forgot_password")

        // when
        let forgotPasswordRequest = SLEndpoint.forgotPassword(baseUrl: baseUrl, email: email).urlRequest

        // then
        XCTAssertEqual(forgotPasswordRequest.url, expectedUrl)
        XCTAssertEqual(forgotPasswordRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(forgotPasswordRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(forgotPasswordRequest)
    }

    func testGenerateVerifyMfaRequest() throws {
        // given
        let expectedKey = String.randomPassword()
        let expectedToken = String.randomPassword()
        let expectedDeviceName = String.randomDeviceName()

        let expectedUrl = baseUrl.append(path: "/api/auth/mfa")

        // when
        let verifyMfaRequest = SLEndpoint.verifyMfa(baseUrl: baseUrl,
                                                    key: expectedKey,
                                                    token: expectedToken,
                                                    deviceName: expectedDeviceName).urlRequest
        let verifyMfaRequestHttpBody = try XCTUnwrap(verifyMfaRequest.httpBody)
        let verifyMfaRequestHttpBodyDict =
            try XCTUnwrap(JSONSerialization.jsonObject(with: verifyMfaRequestHttpBody) as? [String: Any])

        // then
        XCTAssertEqual(verifyMfaRequest.url, expectedUrl)
        XCTAssertEqual(verifyMfaRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(verifyMfaRequestHttpBodyDict["mfa_token"] as? String, expectedToken)
        XCTAssertEqual(verifyMfaRequestHttpBodyDict["mfa_key"] as? String, expectedKey)
        XCTAssertEqual(verifyMfaRequestHttpBodyDict["device"] as? String, expectedDeviceName)
        assertProperlySetJsonContentType(verifyMfaRequest)
    }

    func testGenerateActivateEmailRequest() throws {
        // given
        let expectedEmail = String.randomEmail()
        let expectedCode = String.randomName()

        let expectedUrl = baseUrl.append(path: "/api/auth/activate")

        // when
        let activateEmailRequest =
            SLEndpoint.activateEmail(baseUrl: baseUrl, email: expectedEmail, code: expectedCode).urlRequest
        let activateEmailRequestHttpBody = try XCTUnwrap(activateEmailRequest.httpBody)
        let activateEmailRequestHttpBodyDict =
        try XCTUnwrap(JSONSerialization.jsonObject(with: activateEmailRequestHttpBody) as? [String: Any])

        // then
        XCTAssertEqual(activateEmailRequest.url, expectedUrl)
        XCTAssertEqual(activateEmailRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(activateEmailRequestHttpBodyDict["email"] as? String, expectedEmail)
        XCTAssertEqual(activateEmailRequestHttpBodyDict["code"] as? String, expectedCode)
        assertProperlySetJsonContentType(activateEmailRequest)
    }

    func testGenerateReactivateEmailRequest() throws {
        // given
        let email = String.randomEmail()

        let expectedHttpBody = try JSONSerialization.data(withJSONObject: ["email": email])
        let expectedUrl = baseUrl.append(path: "/api/auth/reactivate")

        // when
        let reactivateEmailRequest = SLEndpoint.reactivateEmail(baseUrl: baseUrl, email: email).urlRequest

        // then
        XCTAssertEqual(reactivateEmailRequest.url, expectedUrl)
        XCTAssertEqual(reactivateEmailRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(reactivateEmailRequest.httpBody, expectedHttpBody)
        assertProperlySetJsonContentType(reactivateEmailRequest)
    }

    func testGenerateSignUpRequest() throws {
        // given
        let expectedEmail = String.randomEmail()
        let expectedPassword = String.randomPassword()
        let expectedUrl = baseUrl.append(path: "/api/auth/register")

        // when
        let signUpRequest =
            SLEndpoint.signUp(baseUrl: baseUrl, email: expectedEmail, password: expectedPassword).urlRequest
        let signUpRequestHttpBody = try XCTUnwrap(signUpRequest.httpBody)
        let signUpRequestHttpBodyDict =
            try XCTUnwrap(JSONSerialization.jsonObject(with: signUpRequestHttpBody) as? [String: Any])

        // then
        XCTAssertEqual(signUpRequest.url, expectedUrl)
        XCTAssertEqual(signUpRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(signUpRequestHttpBodyDict["email"] as? String, expectedEmail)
        XCTAssertEqual(signUpRequestHttpBodyDict["password"] as? String, expectedPassword)
        assertProperlySetJsonContentType(signUpRequest)
    }

    func testGenerateUserOptionsRequestWithHostname() throws {
        // given
        let apiKey = ApiKey.random()
        let hostname = String.randomName()
        let queryItem = URLQueryItem(name: "hostname", value: hostname)

        let expectedUrl = baseUrl.append(path: "/api/v5/alias/options", queryItems: [queryItem])

        // when
        let userOptionsRequest =
            SLEndpoint.userOptions(baseUrl: baseUrl, apiKey: apiKey, hostname: hostname).urlRequest

        // then
        XCTAssertEqual(userOptionsRequest.url, expectedUrl)
        XCTAssertEqual(userOptionsRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(userOptionsRequest, apiKey: apiKey)
    }

    func testGenerateUserOptionsRequestWithoutHostname() throws {
        // given
        let apiKey = ApiKey.random()

        let expectedUrl = baseUrl.append(path: "/api/v5/alias/options")

        // when
        let userOptionsRequest = SLEndpoint.userOptions(baseUrl: baseUrl, apiKey: apiKey, hostname: nil).urlRequest

        // then
        XCTAssertEqual(userOptionsRequest.url, expectedUrl)
        XCTAssertEqual(userOptionsRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(userOptionsRequest, apiKey: apiKey)
    }

    func testGenerateCreateAliasRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let aliasCreationRequest = AliasCreationRequest.random()

        let expectedUrl = baseUrl.append(path: "/api/v3/alias/custom/new")

        // when
        let createAliasRequest =
            SLEndpoint.createAlias(baseUrl: baseUrl,
                                   apiKey: apiKey,
                                   aliasCreationRequest: aliasCreationRequest).urlRequest
        let createAliasHttpBody = try XCTUnwrap(createAliasRequest.httpBody)
        let createAliasHttpBodyDict =
            try XCTUnwrap(JSONSerialization.jsonObject(with: createAliasHttpBody) as? [String: Any])

        // then
        XCTAssertEqual(createAliasRequest.url, expectedUrl)
        XCTAssertEqual(createAliasRequest.httpMethod, HTTPMethod.post)
        XCTAssertEqual(createAliasHttpBodyDict["alias_prefix"] as? String, aliasCreationRequest.prefix)
        XCTAssertEqual(createAliasHttpBodyDict["signed_suffix"] as? String, aliasCreationRequest.suffix.signature)
        XCTAssertEqual(createAliasHttpBodyDict["mailbox_ids"] as? [Int], aliasCreationRequest.mailboxIds)
        XCTAssertEqual(createAliasHttpBodyDict["name"] as? String, aliasCreationRequest.name)
        XCTAssertEqual(createAliasHttpBodyDict["note"] as? String, aliasCreationRequest.note)
        assertProperlySetJsonContentType(createAliasRequest)
        assertProperlyAttachedApiKey(createAliasRequest, apiKey: apiKey)
    }

    func testGenerateUserSettingsRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let expectedUrl = baseUrl.append(path: "/api/setting")

        // when
        let userSettingsRequest = SLEndpoint.userSettings(baseUrl: baseUrl, apiKey: apiKey).urlRequest

        // then
        XCTAssertEqual(userSettingsRequest.url, expectedUrl)
        XCTAssertEqual(userSettingsRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(userSettingsRequest, apiKey: apiKey)
    }

    func testGenerateGetDomainLitesRequest() throws {
        // given
        let apiKey = ApiKey.random()
        let expectedUrl = baseUrl.append(path: "/api/v2/setting/domains")

        // when
        let getDomainLitesRequest = SLEndpoint.getDomainLites(baseUrl: baseUrl, apiKey: apiKey).urlRequest

        // then
        XCTAssertEqual(getDomainLitesRequest.url, expectedUrl)
        XCTAssertEqual(getDomainLitesRequest.httpMethod, HTTPMethod.get)
        assertProperlyAttachedApiKey(getDomainLitesRequest, apiKey: apiKey)
    }
}
