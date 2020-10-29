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
                             deviceName: String) -> URLRequest? {
        guard let loginUrl = baseUrl.componentsFor(endpoint: .login).url,
              var request = try? URLRequest(url: loginUrl, method: .post) else {
            return nil
        }

        let requestDict = ["email": email, "password": password, "device": deviceName]

        guard let requestData = try? JSONEncoder().encode(requestDict) else { return  nil }

        request.httpBody = requestData
        return request
    }
}
