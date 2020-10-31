//
//  NetworkEngineMock.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
@testable import SimpleLogin
import XCTest

final class NetworkEngineMock: NetworkEngine {
    let data: Data?
    let statusCode: Int?
    let error: Error?

    init(data: Data?, statusCode: Int?, error: Error?) {
        self.data = data
        self.statusCode = statusCode
        self.error = error
    }

    // swiftlint:disable force_unwrapping
    func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler) {
        if let statusCode = statusCode {
            let response =
                HTTPURLResponse(url: urlRequest.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
            completionHandler(data, response, error)
        } else {
            completionHandler(data, nil, error)
        }
    }

    static func givenEngineWithDummyDataAndStatusCode(_ statusCode: Int) throws -> NetworkEngine {
        let data = try XCTUnwrap(Data.fromJson(fileName: "DummyData"))
        return NetworkEngineMock(data: data, statusCode: statusCode, error: nil)
    }

    static func givenEngineWithUnknownError() -> (engine: NetworkEngineMock, error: SLError) {
        let error = NSError(domain: "io.simplelogin.test", code: 999, userInfo: nil)
        let engine = NetworkEngineMock(data: nil, statusCode: 999, error: error)
        let slError = SLError.unknownError(error: error)

        return (engine, slError)
    }

    static func givenEngineWithUnknownErrorWithStatusCode() throws -> (engine: NetworkEngineMock, error: SLError) {
        let dummyData = try Data.fromJson(fileName: "DummyData")
        let engine = NetworkEngineMock(data: dummyData, statusCode: 998, error: nil)
        let slError = SLError.unknownErrorWithStatusCode(statusCode: 998)

        return (engine, slError)
    }
}
