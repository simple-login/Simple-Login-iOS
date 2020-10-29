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

// swiftlint:disable nesting
// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
extension SLClientTests {
    func testLoginSuccessWithStatusCode200() throws {
        // given
        class NetworkEngineMock: NetworkEngine {
            func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler) {
                let response =
                    HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
                let data = try! XCTUnwrap(Data.fromJson(fileName: "POST_login_Response"))
                completionHandler(data, response, nil)
            }
        }

        // when
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let engine = NetworkEngineMock()
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
        class NetworkEngineMock: NetworkEngine {
            func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler) {
                let response =
                    HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
                let data = try! XCTUnwrap(Data.fromJson(fileName: "POST_login_MissingValueResponse"))
                completionHandler(data, response, nil)
            }
        }

        // when
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let engine = NetworkEngineMock()
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
