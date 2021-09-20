//
//  KeychainService.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/09/2021.
//

import KeychainAccess
import SimpleLoginPackage

private let kApiKey = "API_KEY"

struct KeychainService {
    private let keychain = Keychain(service: "975H7B86B7.io.simplelogin.ios-app.shared")

    private init() {}

    static let shared = KeychainService()

    func setApiKey(_ apiKey: ApiKey?) throws {
        if let apiKey = apiKey {
            try keychain.set(apiKey.value, key: kApiKey)
        } else {
            try keychain.remove(kApiKey)
        }
    }

    func getApiKey() -> ApiKey? {
        guard let apiKeyValue = try? keychain.getString(kApiKey) else { return nil }
        return ApiKey(value: apiKeyValue)
    }
}
