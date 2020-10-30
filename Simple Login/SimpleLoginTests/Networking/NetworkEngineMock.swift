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
}
