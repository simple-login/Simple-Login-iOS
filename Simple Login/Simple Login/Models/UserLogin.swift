//
//  UserLogin.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct UserLogin: Decodable {
    let apiKey: ApiKey
    let email: String
    let isMfaEnabled: Bool
    let mfaKey: String?
    let name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        let apiKeyString = try container.decode(String.self, forKey: .apiKey)
        self.apiKey = ApiKey(value: apiKeyString)
        self.email = try container.decode(String.self, forKey: .email)
        self.isMfaEnabled = try container.decode(Bool.self, forKey: .isMfaEnabled)
        self.mfaKey = try container.decode(String?.self, forKey: .mfaKey)
        self.name = try container.decode(String.self, forKey: .name)
    }

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case apiKey = "api_key"
        case email = "email"
        case isMfaEnabled = "mfa_enabled"
        case mfaKey = "mfa_key"
        case name = "name"
    }
}
