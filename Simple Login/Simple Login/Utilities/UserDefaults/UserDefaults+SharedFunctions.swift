//
//  UserDefaults+SharedFunctions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

fileprivate let defaults = UserDefaults()

extension UserDefaults {
    // MARK: - API URL
    private static let apiUrlKey = "ApiUrl"
    private static let defaultApiUrl = "https://app.simplelogin.io"
    
    static func getApiUrl() -> String {
        return defaults.string(forKey: apiUrlKey) ?? defaultApiUrl
    }
    
    static func setApiUrl(_ apiUrl: String) {
        defaults.set(apiUrl, forKey: apiUrlKey)
    }
    
    static func resetApiUrl() {
        defaults.set(defaultApiUrl, forKey: apiUrlKey)
    }
}
