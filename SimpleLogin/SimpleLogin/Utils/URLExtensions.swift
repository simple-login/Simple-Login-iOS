//
//  URLExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import Foundation

extension URL {
    func notWwwHostname() -> String? {
        var components = host?.components(separatedBy: ".")
        let hostName = components?.removeFirst()
        if hostName == "www" {
            return components?.removeFirst()
        }
        return hostName
    }
}
