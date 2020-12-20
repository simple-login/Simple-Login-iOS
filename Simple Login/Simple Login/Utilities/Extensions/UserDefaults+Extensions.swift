//
//  UserDefaults+Extensions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

// swiftlint:disable:next prefixed_toplevel_constant
fileprivate let defaults = UserDefaults()

extension UserDefaults {
    // MARK: - Review
    private static let numberOfSessionKey = "NumberOfSessionKey"

    static func numberOfSessions() -> Int { defaults.integer(forKey: numberOfSessionKey) }

    static func increaseNumberOfSessions() {
        let numberOfSessions = defaults.integer(forKey: numberOfSessionKey)
        defaults.set(numberOfSessions + 1, forKey: numberOfSessionKey)
    }

    private static let didMakeAReviewKey = "DidMakeAReviewKey"

    static func didMakeAReview() -> Bool { defaults.bool(forKey: didMakeAReviewKey) }

    static func setDidMakeAReview() {
        defaults.set(true, forKey: didMakeAReviewKey)
    }

    // Biometric authentication
    private static let activeBiometricAuthKey = "ActiveBiometricAuthKey"

    static func activeBiometricAuth() -> Bool { defaults.bool(forKey: activeBiometricAuthKey) }

    static func activateBiometricAuth() {
        defaults.set(true, forKey: activeBiometricAuthKey)
    }

    static func deactivateBiometricAuth() {
        defaults.set(false, forKey: activeBiometricAuthKey)
    }
}
