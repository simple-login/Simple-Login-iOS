//
//  SLClientTests+fetchUserInfoTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchUserInfoTests: XCTestCase {
    func whenFetchingUserInfoWith(engine: NetworkEngine) throws -> (userInfo: UserInfo?, error: SLError?) {
        var storedUserInfo: UserInfo?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchUserInfo(apiKey: ApiKey(value: "")) { result in
            switch result {
            case .success(let userInfo): storedUserInfo = userInfo
            case .failure(let error): storedError = error
            }
        }

        return (storedUserInfo, storedError)
    }

    func testFetchUserInfoFailureWithUnknownError() throws {
        // given
        let error = NSError(domain: "io.simplelogin.test", code: 999, userInfo: nil)
        let engine = NetworkEngineMock(data: nil, statusCode: 999, error: error)
        let expectedError = SLError.unknownError(error: error)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchUserInfoFailureWithUnknownResponseStatusCode() throws {
        // given
        let engine = NetworkEngineMock(data: nil, statusCode: nil, error: nil)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertEqual(result.error, SLError.unknownResponseStatusCode)
    }

    func testFetchUserInfoSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "UserInfo_Valid"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNotNil(result.userInfo)
        XCTAssertNil(result.error)
    }

    func testFetchUserInfoFailureWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "UserInfo_MissingValue"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertNotNil(result.error)
    }

    func testFetchUserInfoFailureWithStatusCode401() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(401)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertEqual(result.error, SLError.invalidApiKey)
    }

    func testFetchUserInfoFailureWithStatusCode500() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testFetchUserInfoFailureWithStatusCode502() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenFetchingUserInfoWith(engine: engine)

        // then
        XCTAssertNil(result.userInfo)
        XCTAssertEqual(result.error, SLError.badGateway)
    }
}
