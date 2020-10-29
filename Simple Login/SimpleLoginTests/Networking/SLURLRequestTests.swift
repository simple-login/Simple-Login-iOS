//
//  SLURLRequestTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLURLRequestTests: XCTestCase {
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

    func urlComponentsFor(endpoint: SLEndpoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endpoint.rawValue

        return components
    }

    func testCorrectlyGenerateLoginRequest() throws {
        // given
        let email = "john.doe@example.com"
        let password = "johndoe"
        let device = "iphone"
        let requestDict = ["email": email, "password": password, "device": device]
        let requestData = try JSONEncoder().encode(requestDict)

        let components = urlComponentsFor(endpoint: .login)
        let url = try XCTUnwrap(components.url)
        var expectedUrlRequest = try XCTUnwrap(URLRequest(url: url, method: .post))
        expectedUrlRequest.httpBody = requestData

        // when
        let loginRequest =
            SLURLRequest.loginRequest(from: baseUrl, email: email, password: password, deviceName: device)

        // then
        XCTAssertEqual(loginRequest, expectedUrlRequest)
    }
}
