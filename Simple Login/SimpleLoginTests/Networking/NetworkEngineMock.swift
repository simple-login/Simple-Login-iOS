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

    static func givenEngineWithDummyDataAndStatusCode(_ statusCode: Int) throws -> (engine: NetworkEngine, error: SLError) {
        let data = try XCTUnwrap(Data.fromJson(fileName: "DummyData"))
        let engine = NetworkEngineMock(data: data, statusCode: statusCode, error: nil)
        let error = SLError.unknownErrorWithStatusCode(statusCode: statusCode)
        return (engine, error)
    }

    static func givenEngineWithUnknownError() -> (engine: NetworkEngineMock, error: SLError) {
        let error = NSError(domain: "io.simplelogin.test", code: 999, userInfo: nil)
        let engine = NetworkEngineMock(data: nil, statusCode: 999, error: error)
        let slError = SLError.unknownError(error: error)

        return (engine, slError)
    }

    static func givenEngineWithUnknownErrorWith(statusCode: Int) throws
    -> (engine: NetworkEngineMock, error: SLError) {
        let dummyData = try Data.fromJson(fileName: "DummyData")
        let engine = NetworkEngineMock(data: dummyData, statusCode: statusCode, error: nil)
        let slError = SLError.unknownErrorWithStatusCode(statusCode: statusCode)

        return (engine, slError)
    }

    static func givenEngineWithSpecificError(statusCode: Int) throws
    -> (engine: NetworkEngineMock, error: SLError) {
        let data = try XCTUnwrap(Data.fromJson(fileName: "ErrorMessage"))
        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
        let error = SLError.badRequest(description: errorMessage.value)
        let engine = NetworkEngineMock(data: data, statusCode: statusCode, error: nil)

        return (engine, error)
    }
}
