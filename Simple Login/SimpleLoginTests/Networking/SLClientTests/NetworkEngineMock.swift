//
//  NetworkEngineMock.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
@testable import SimpleLogin

class NetworkEngineMock: NetworkEngine {
    let data: Data?
    let statusCode: Int

    init(data: Data?, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }

    // swiftlint:disable force_unwrapping
    func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler) {
        let response =
            HTTPURLResponse(url: urlRequest.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        completionHandler(data, response, nil)
    }
}
