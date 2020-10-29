//
//  SLURLRequest.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SLURLRequest {
    static func loginRequest(from baseUrl: URL,
                             email: String,
                             password: String,
                             deviceName: String) throws -> URLRequest {
        guard let loginUrl = baseUrl.componentsFor(endpoint: .login).url else {
            throw SLError.failedToGenerateUrlForSLEndpoint(baseUrl: baseUrl, endpoint: .login)
        }
        var request = try URLRequest(url: loginUrl, method: .post)

        let requestDict = ["email": email, "password": password, "device": deviceName]
        let requestData = try JSONEncoder().encode(requestDict)

        request.httpBody = requestData
        return request
    }
}
