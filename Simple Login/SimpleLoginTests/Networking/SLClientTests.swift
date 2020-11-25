//
//  SLClientTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

// swiftlint:disable file_length
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
        client.login(email: String.randomEmail(),
                     password: String.randomPassword(),
                     deviceName: String.randomDeviceName()) { result in
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
        client.fetchUserInfo(apiKey: ApiKey.random()) { result in
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
        client.fetchAliases(apiKey: ApiKey.random(), page: Int.randomPageId(), searchTerm: nil) { result in
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
        client.fetchAliasActivities(apiKey: ApiKey.random(),
                                    aliasId: Int.randomIdentifer(),
                                    page: Int.randomPageId()) { result in
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
        client.fetchMailboxes(apiKey: ApiKey.random()) { result in
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
        client.fetchContacts(apiKey: ApiKey.random(),
                             aliasId: Int.randomIdentifer(),
                             page: Int.randomPageId()) { result in
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
        client.updateAliasMailboxes(apiKey: ApiKey.random(),
                                    aliasId: Int.randomIdentifer(),
                                    mailboxIds: [Int.randomIdentifer(), Int.randomIdentifer()]) { result in
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
        client.updateAliasName(apiKey: ApiKey.random(),
                               aliasId: Int.randomIdentifer(),
                               name: String.randomName()) { result in
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
        client.updateAliasNote(apiKey: ApiKey.random(),
                               aliasId: Int.randomIdentifer(),
                               note: nil) { result in
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
        client.randomAlias(apiKey: ApiKey.random(), randomMode: .uuid) { result in
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
        client.toggleAlias(apiKey: ApiKey.random(), aliasId: Int.randomIdentifer()) { result in
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
        client.deleteAlias(apiKey: ApiKey.random(), aliasId: Int.randomIdentifer()) { result in
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
        client.getAlias(apiKey: ApiKey.random(), aliasId: Int.randomIdentifer()) { result in
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
        client.createContact(apiKey: ApiKey.random(),
                             aliasId: Int.randomIdentifer(),
                             email: String.randomEmail()) { result in
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
        client.deleteContact(apiKey: ApiKey.random(), contactId: Int.randomIdentifer()) { result in
            switch result {
            case .success(let deleted): storedDeleted = deleted
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedDeleted)
        XCTAssertNil(storedError)
    }

    func testCreateMailbox() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Mailbox")

        // when
        var storedMailbox: Mailbox?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.createMailbox(apiKey: ApiKey.random(), email: String.randomEmail()) { result in
            switch result {
            case .success(let mailbox): storedMailbox = mailbox
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedMailbox)
        XCTAssertNil(storedError)
    }

    func testDeleteMailbox() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Deleted")

        // when
        var storedDeleted: Deleted?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.deleteMailbox(apiKey: ApiKey.random(), mailboxId: Int.randomIdentifer()) { result in
            switch result {
            case .success(let deleted): storedDeleted = deleted
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedDeleted)
        XCTAssertNil(storedError)
    }

    func testMakeDefaultMailbox() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Updated")

        // when
        var storedUpdated: Updated?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.makeDefaultMailbox(apiKey: ApiKey.random(), mailboxId: Int.randomIdentifer()) { result in
            switch result {
            case .success(let updated): storedUpdated = updated
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUpdated)
        XCTAssertNil(storedError)
    }

    func testProcessPayment() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Ok")

        // when
        var storedOk: Ok?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.processPayment(apiKey: ApiKey.random(), receiptData: String.randomPassword()) { result in
            switch result {
            case .success(let ok): storedOk = ok
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedOk?.value, true)
        XCTAssertNil(storedError)
    }

    func testForgotPassword() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Ok")

        // when
        var storedOk: Ok?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.forgotPassword(email: String.randomEmail()) { result in
            switch result {
            case .success(let ok): storedOk = ok
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedOk?.value, true)
        XCTAssertNil(storedError)
    }

    func testVerifyMfa() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("ApiKey")

        // when
        var storedApiKey: ApiKey?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.verifyMfa(key: String.randomPassword(),
                         token: String.randomPassword(),
                         deviceName: String.randomName()) { result in
            switch result {
            case .success(let apiKey): storedApiKey = apiKey
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedApiKey)
        XCTAssertNil(storedError)
    }

    func testActivateEmail() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Message")

        // when
        var storedMessage: Message?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.activate(email: String.randomEmail(), code: String.randomPassword()) { result in
            switch result {
            case .success(let message): storedMessage = message
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedMessage)
        XCTAssertNil(storedError)
    }

    func testReactivateEmail() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Message")

        // when
        var storedMessage: Message?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.reactivate(email: String.randomEmail()) { result in
            switch result {
            case .success(let message): storedMessage = message
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedMessage)
        XCTAssertNil(storedError)
    }

    func testSignUp() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Message")

        // when
        var storedMessage: Message?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.signUp(email: String.randomEmail(), password: String.randomPassword()) { result in
            switch result {
            case .success(let message): storedMessage = message
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedMessage)
        XCTAssertNil(storedError)
    }

    func testFetchUserOptions() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserOptions")

        // when
        var storedUserOptions: UserOptions?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchUserOptions(apiKey: ApiKey.random(), hostname: String.randomName()) { result in
            switch result {
            case .success(let userOptions): storedUserOptions = userOptions
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUserOptions)
        XCTAssertNil(storedError)
    }

    func testCreateAlias() throws {
        // given
        let aliasCreationRequest = AliasCreationRequest.random()
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("Alias")

        // when
        var storedAlias: Alias?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.createAlias(apiKey: ApiKey.random(), aliasCreationRequest: aliasCreationRequest) { result in
            switch result {
            case .success(let alias): storedAlias = alias
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedAlias)
        XCTAssertNil(storedError)
    }

    func testFetchUserSettings() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserSettings")

        // when
        var storedUserSettings: UserSettings?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchUserSettings(apiKey: ApiKey.random()) { result in
            switch result {
            case .success(let userSettings): storedUserSettings = userSettings
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUserSettings)
        XCTAssertNil(storedError)
    }

    func testGetDomainLites() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("DomainLites")

        // when
        var storedDomainLites: [DomainLite]?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.getDomainLites(apiKey: ApiKey.random()) { result in
            switch result {
            case .success(let domainLites): storedDomainLites = domainLites
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedDomainLites)
        XCTAssertEqual(storedDomainLites?.count, 4)
        XCTAssertNil(storedError)
    }

    func testUpdateUserSettings() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserSettings")

        // when
        var storedUserSettings: UserSettings?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.updateUserSettings(apiKey: ApiKey.random(), option: UserSettings.Option.random()) { result in
            switch result {
            case .success(let userSettings): storedUserSettings = userSettings
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUserSettings)
        XCTAssertNil(storedError)
    }

    func testUpdateProfilePicture() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDataFromFile("UserInfo")

        // when
        var storedUserInfo: UserInfo?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.updateProfilePicture(apiKey: ApiKey.random(), base64String: String.randomName()) { result in
            switch result {
            case .success(let userInfo): storedUserInfo = userInfo
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNotNil(storedUserInfo)
        XCTAssertNil(storedError)
    }
}
