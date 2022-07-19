//
//  SLKeychainService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import KeychainAccess

enum SLKeychainService {
    private static let keychainService = Keychain(service: "72VC334CSX.io.simplelogin.ios-app.shared")
    private static let API_KEY = "API_KEY"

    static func setApiKey(_ apiKey: ApiKey) throws {
        try keychainService.set(apiKey.value, key: API_KEY)
    }

    static func getApiKey() -> ApiKey? {
        if let apiKeyValue = try? keychainService.getString(API_KEY) {
            return ApiKey(value: apiKeyValue)
        } else {
            return nil
        }
    }

    static func removeApiKey() throws {
        try keychainService.remove(API_KEY)
    }
}
