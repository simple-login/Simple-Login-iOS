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
        let expectedBaseUrl = try XCTUnwrap(URL(string: Settings.shared.apiUrl))

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

    func testUpdateBaseUrlString() throws {
        // given
        let sut = try SLClient()

        let validUrlString = "https://example.com"
        let expectedUrl = try XCTUnwrap(URL(string: validUrlString))

        // when
        sut.updateBaseUrlString(validUrlString)

        // then
        XCTAssertEqual(sut.baseUrl, expectedUrl)
    }
}

// MARK: - Login test: test every path
extension SLClientTests {
    // Test all possible paths when calling makeCall(to:expectedObjectType:completion)
    // take login case as example
    func whenLoginWith(engine: NetworkEngine) throws -> (userLogin: UserLogin?, error: SLError?) {
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.login(email: "", password: "", deviceName: "") { result in
            switch result {
            case .success(let userLogin): storedUserLogin = userLogin
            case .failure(let error): storedError = error
            }
        }

        return (storedUserLogin, storedError)
    }

    func testLoginFailureWithUnknownError() throws {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithUnknownError()

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, expectedError)
    }

    func testLoginSuccessWithStatusCode200() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserLogin")

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNotNil(result.userLogin)
        XCTAssertNil(result.error)
    }

    func testLoginFailureWithStatusCode200() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserLogin_MissingValue")

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.userLogin)
    }

    func testLoginFailureWithStatusCode400() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 400)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, expectedError)
    }

    func testLoginFailureWithStatusCode400AndUnknownErrorMessage() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(400)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, expectedError)
    }

    func testLoginFailureWithStatusCode500() throws {
        // given
        let (engine, _) = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testLoginFailureWithStatusCode502() throws {
        // given
        let (engine, _) = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, SLError.badGateway)
    }

    func testLoginFailureWithUnknownErrorWithStatusCode999() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithUnknownErrorWith(statusCode: 999)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, expectedError)
    }
}

extension SLClientTests {
    func testFetchUserInfo() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserInfo")

        // when
        var storedUserInfo: UserInfo?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchUserInfo(apiKey: ApiKey(value: "")) { result in
            switch result {
            case .success(let userInfo): storedUserInfo = userInfo
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUserInfo)
        XCTAssertNil(storedError)
    }

    func testFetchAliases() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("AliasArray")

        // when
        var storedAliasArray: AliasArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchAliases(apiKey: ApiKey(value: ""), page: 10, searchTerm: nil) { result in
            switch result {
            case .success(let aliasArray): storedAliasArray = aliasArray
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedAliasArray)
        XCTAssertNil(storedError)
    }

    func testFetchAliasActivities() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("AliasActivityArray")

        // when
        var storedAliasActivitesArray: AliasActivityArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchAliasActivities(apiKey: ApiKey(value: ""), aliasId: 2_369, page: 10) { result in
            switch result {
            case .success(let aliasActivitesArray): storedAliasActivitesArray = aliasActivitesArray
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedAliasActivitesArray)
        XCTAssertNil(storedError)
    }

    func testFetchMailboxes() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("MailboxArray")

        // when
        var storedMailboxArray: MailboxArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchMailboxes(apiKey: ApiKey(value: "")) { result in
            switch result {
            case .success(let mailboxArray): storedMailboxArray = mailboxArray
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedMailboxArray)
        XCTAssertNil(storedError)
    }

    func testFetchContacts() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("ContactArray")

        // when
        var storedContactArray: ContactArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchContacts(apiKey: ApiKey(value: ""),
                             aliasId: 128,
                             page: 12) { result in
            switch result {
            case .success(let contactArray): storedContactArray = contactArray
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedContactArray)
        XCTAssertNil(storedError)
    }

    func testUpdateAliasMailboxes() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Ok")

        // when
        var storedOk: Ok?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.updateAliasMailboxes(apiKey: ApiKey(value: ""), aliasId: 332, mailboxIds: [12, 291]) { result in
            switch result {
            case .success(let ok): storedOk = ok
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedOk?.value, true)
        XCTAssertNil(storedError)
    }

    func testUpdateAliasName() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Ok")

        // when
        var storedOk: Ok?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.updateAliasName(apiKey: ApiKey(value: ""), aliasId: 2_441, name: "") { result in
            switch result {
            case .success(let ok): storedOk = ok
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedOk?.value, true)
        XCTAssertNil(storedError)
    }

    func testUpdateAliasNote() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Ok")

        // when
        var storedOk: Ok?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.updateAliasNote(apiKey: ApiKey(value: ""), aliasId: 2_441, note: nil) { result in
            switch result {
            case .success(let ok): storedOk = ok
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedOk?.value, true)
        XCTAssertNil(storedError)
    }

    func testRandomAlias() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Alias")

        // when
        var storedAlias: Alias?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.randomAlias(apiKey: ApiKey(value: ""), randomMode: .uuid) { result in
            switch result {
            case .success(let alias): storedAlias = alias
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedAlias)
        XCTAssertNil(storedError)
    }

    func testToggleAlias() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Enabled")

        // when
        var storedEnabled: Enabled?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.toggleAlias(apiKey: ApiKey(value: ""), aliasId: 18) { result in
            switch result {
            case .success(let enabled): storedEnabled = enabled
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedEnabled)
        XCTAssertNil(storedError)
    }

    func testDeleteAlias() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Deleted")

        // when
        var storedDeleted: Deleted?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.deleteAlias(apiKey: ApiKey(value: ""), aliasId: 233) { result in
            switch result {
            case .success(let deleted): storedDeleted = deleted
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedDeleted)
        XCTAssertNil(storedError)
    }

    func testGetAlias() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Alias")

        // when
        var storedAlias: Alias?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.getAlias(apiKey: ApiKey(value: ""), aliasId: 553) { result in
            switch result {
            case .success(let alias): storedAlias = alias
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedAlias)
        XCTAssertNil(storedError)
    }

    func testCreateContact() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Contact")

        // when
        var storedContact: Contact?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.createContact(apiKey: ApiKey(value: ""), aliasId: 299, email: "john.doe@example.com") { result in
            switch result {
            case .success(let contatc): storedContact = contatc
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedContact)
        XCTAssertNil(storedError)
    }

    func testDeleteContact() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Deleted")

        // when
        var storedDeleted: Deleted?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.deleteContact(apiKey: ApiKey(value: ""), contactId: 12) { result in
            switch result {
            case .success(let deleted): storedDeleted = deleted
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedDeleted)
        XCTAssertNil(storedError)
    }
}
