//
//  Settings.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 31/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class Settings {
    private init() {}
    static let shared = Settings()
    
    // API URL
    private static let defaultApiUrl = "https://app.simplelogin.io"
    
    @UserDefault("api_url", defaultValue: defaultApiUrl)
    var apiUrl: String {
        didSet {
            SLApiService.shared.refreshBaseUrl()
        }
    }
    
    func resetApiUrl() {
        apiUrl = Self.defaultApiUrl
    }
    
    // First run
    @UserDefault("is_first_run", defaultValue: true)
    var isFirstRun: Bool
    
    // Delete & random alias instruction
    @UserDefault("showed_delete_and_random_alias_instruction", defaultValue: false)
    var showedDeleteAndRandomAliasInstruction: Bool
}
