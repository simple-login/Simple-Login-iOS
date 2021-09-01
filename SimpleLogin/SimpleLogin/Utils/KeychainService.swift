//
//  KeychainService.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/09/2021.
//

import KeychainAccess

final class KeychainService {
    private let keychain = Keychain(service: "975H7B86B7.io.simplelogin.ios-app.shared")

    private init() {}

    static let shared = KeychainService()
}
