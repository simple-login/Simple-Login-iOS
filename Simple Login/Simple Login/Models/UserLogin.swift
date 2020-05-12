//
//  UserLogin.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct UserLogin {
    let apiKey: String?
    let isMfaEnabled: Bool
    let mfaKey: String?
    let name: String?
    
    init(fromData data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }
        
        let apiKey = jsonDictionary["api_key"] as? String
        let isMfaEnabled = jsonDictionary["mfa_enabled"] as? Bool
        let mfaKey = jsonDictionary["mfa_key"] as? String
        let name = jsonDictionary["name"] as? String
        
        if let isMfaEnabled = isMfaEnabled {
            self.apiKey = apiKey
            self.isMfaEnabled = isMfaEnabled
            self.mfaKey = mfaKey
            self.name = name
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
