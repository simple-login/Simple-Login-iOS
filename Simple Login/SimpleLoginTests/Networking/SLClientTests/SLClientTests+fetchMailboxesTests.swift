//
//  SLClientTests+fetchMailboxesTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchMailboxesTests: XCTestCase {
    func whenFetchingMailboxesWith(engine: NetworkEngine) throws
    -> (mailboxArray: MailboxArray?, error: SLError?) {
        var storedMailboxArray: MailboxArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchMailboxes(apiKey: ApiKey(value: "")) { result in
            switch result {
            case .success(let mailboxArray): storedMailboxArray = mailboxArray
            case .failure(let error): storedError = error
            }
        }

        return (storedMailboxArray, storedError)
    }

    func testFetchMailboxesFailureWithUnknownError() throws {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithUnknownError()

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchMailboxesFailureWithUnknownResponseStatusCode() throws {
        // given
        let engine = NetworkEngineMock(data: nil, statusCode: nil, error: nil)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, SLError.unknownResponseStatusCode)
    }

    func testFetchMailboxesSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "MailboxArray"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNotNil(result.mailboxArray)
        XCTAssertNil(result.error)
    }

    func testFetchMailboxesFailureWithStatusCode400() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 400)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchMailboxesFailureWithStatusCode401() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 401)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchMailboxesFailureWithStatusCode500() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testFetchMailboxesFailureWithStatusCode502() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, SLError.badGateway)
    }

    func testFetchMailboxesWithUnknownErrorWithStatusCode() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithUnknownErrorWithStatusCode()

        // when
        let result = try whenFetchingMailboxesWith(engine: engine)

        // then
        XCTAssertNil(result.mailboxArray)
        XCTAssertEqual(result.error, expectedError)
    }
}
