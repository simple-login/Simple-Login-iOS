//
//  SLKeychainService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import KeychainAccess

final class SLKeychainService {
    private static let keychainService = Keychain()
    private static let API_KEY = "API_KEY"
    
    static func setApiKey(_ apiKey: String) throws {
        try keychainService.set(apiKey, key: API_KEY)
    }
    
    static func getApiKey() -> String? {
        do {
            return try keychainService.getString(API_KEY)
        } catch {
            return nil
        }
    }
    
    static func removeApiKey() throws {
        try keychainService.remove(API_KEY)
    }
}
