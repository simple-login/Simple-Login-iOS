//
//  SLClientTests+loginTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
@testable import SimpleLogin
import XCTest

extension SLClientTests {
    func testLoginSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "POST_login_Response"))
        let engine = NetworkEngineMock(data: data, statusCode: 200)

        // when
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let sut = try SLClient(engine: engine)
        sut.login(email: "", password: "", deviceName: "") { result in
            switch result {
            case .success(let userLogin): storedUserLogin = userLogin
            case .failure(let error): storedError = error
            }
        }

        XCTAssertNotNil(storedUserLogin)
        XCTAssertNil(storedError)
    }

    func testLoginFailureWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "POST_login_MissingValueResponse"))
        let engine = NetworkEngineMock(data: data, statusCode: 200)

        // when
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let sut = try SLClient(engine: engine)
        sut.login(email: "", password: "", deviceName: "") { result in
            switch result {
            case .success(let userLogin): storedUserLogin = userLogin
            case .failure(let error): storedError = error
            }
        }

        XCTAssertNotNil(storedError)
        XCTAssertNil(storedUserLogin)
    }
}
