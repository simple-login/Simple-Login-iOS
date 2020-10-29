//
//  SLEndpoint.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SLEndpoint: String {
    case login = "/api/auth/login"
}

extension URL {
    func componentsFor(endpoint: SLEndpoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endpoint.rawValue

        return components
    }
}
