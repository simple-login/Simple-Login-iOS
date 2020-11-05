//
//  String+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 03/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum AllowedLetters: String {
    case lowercase = "abcdefghijklmnopqrstuvwxyz"
    case lowercaseUppercase = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    case lowercaseUppercaseDigit = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
}

// swiftlint:disable force_unwrapping
extension String {
    static func random(allowedLetters: AllowedLetters, length: Int) -> String {
        String((0..<length).map { _ in allowedLetters.rawValue.randomElement()! })
    }

    static func randomName() -> String {
        random(allowedLetters: .lowercaseUppercaseDigit, length: 20)
    }

    static func randomNullableName() -> String? {
        let isNull = Bool.random()

        if isNull { return nil }
        return randomName()
    }

    static func randomEmail() -> String {
        let username = random(allowedLetters: .lowercase, length: 10)
        let hostname = random(allowedLetters: .lowercase, length: 5)
        let domain = ["com", "co", "io", "net", "me"].randomElement()!

        return "\(username)@\(hostname).\(domain)"
    }

    static func randomPassword() -> String {
        random(allowedLetters: .lowercaseUppercaseDigit, length: 100)
    }

    static func randomDeviceName() -> String {
        random(allowedLetters: .lowercaseUppercaseDigit, length: 15)
    }
}
