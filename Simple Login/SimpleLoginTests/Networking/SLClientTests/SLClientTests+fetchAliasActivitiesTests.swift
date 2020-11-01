//
//  SLClientTests+fetchAliasActivitiesTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchAliasActivitiesTests: XCTestCase {
    func whenFetchingAliasActivitiesWith(engine: NetworkEngine) throws
    -> (aliasActivitesArray: AliasActivityArray?, error: SLError?) {
        var storedAliasActivitesArray: AliasActivityArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchAliasActivities(apiKey: ApiKey(value: ""), aliasId: 2_369, page: 10) { result in
            switch result {
            case .success(let aliasActivitesArray): storedAliasActivitesArray = aliasActivitesArray
            case .failure(let error): storedError = error
            }
        }

        return (storedAliasActivitesArray, storedError)
    }

    func testFetchAliasActivitiesFailureWithUnknownError() throws {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithUnknownError()

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchAliasActivitiesFailureWithUnknownResponseStatusCode() throws {
        // given
        let engine = NetworkEngineMock(data: nil, statusCode: nil, error: nil)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, SLError.unknownResponseStatusCode)
    }

    func testFetchAliasActivitiesSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "AliasActivityArray"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNotNil(result.aliasActivitesArray)
        XCTAssertNil(result.error)
    }

    func testAliasActivitiesFailureWithStatusCode400() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 400)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchUserInfoFailureWithStatusCode401() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 401)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchUserInfoFailureWithStatusCode500() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testFetchUserInfoFailureWithStatusCode502() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, SLError.badGateway)
    }

    func testFetchUserInfoFailureWithUnknownErrorWithStatusCode() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithUnknownErrorWithStatusCode()

        // when
        let result = try whenFetchingAliasActivitiesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasActivitesArray)
        XCTAssertEqual(result.error, expectedError)
    }
}
