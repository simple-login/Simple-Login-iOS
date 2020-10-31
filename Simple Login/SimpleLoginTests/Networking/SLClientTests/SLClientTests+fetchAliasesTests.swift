//
//  SLClientTests+fetchAliasesTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchAliasesTests: XCTestCase {
    func whenFetchingAliasesWith(engine: NetworkEngine) throws -> (aliasArray: AliasArray?, error: SLError?) {
        var storedAliasArray: AliasArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchAliases(apiKey: ApiKey(value: ""), page: 10, searchTerm: nil) { result in
            switch result {
            case .success(let aliasArray): storedAliasArray = aliasArray
            case .failure(let error): storedError = error
            }
        }

        return (storedAliasArray, storedError)
    }

    func testFetchUserInfoFailureWithUnknownError() throws {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithUnknownError()

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchUserInfoFailureWithUnknownResponseStatusCode() throws {
        // given
        let engine = NetworkEngineMock(data: nil, statusCode: nil, error: nil)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.unknownResponseStatusCode)
    }

    func testFetchUserInfoSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "AliasArray"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNotNil(result.aliasArray)
        XCTAssertNil(result.error)
    }

    func testUserInfoFailureWithStatusCode400() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "ErrorMessage"))
        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
        let expectedError = SLError.badRequest(description: errorMessage.value)
        let engine = NetworkEngineMock(data: data, statusCode: 400, error: nil)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchUserInfoFailureWithStatusCode401() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(401)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.invalidApiKey)
    }

    func testFetchUserInfoFailureWithStatusCode500() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testFetchUserInfoFailureWithStatusCode502() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.badGateway)
    }

    func testFetchUserInfoFailureWithUnknownErrorWithStatusCode() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithUnknownErrorWithStatusCode()

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }
}
