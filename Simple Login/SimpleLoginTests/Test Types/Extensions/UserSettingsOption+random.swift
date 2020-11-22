//
//  UserSettingsOption+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin

extension UserSettings.Option {
    static func random() -> UserSettings.Option {
        let randomInt = Int.random(in: 0...3)

        switch randomInt {
        case 0:
            if Bool.random() {
                return .randomMode(.uuid)
            }
            return .randomMode(.word)

        case 1:
            return .notification(Bool.random())

        case 2:
            return .randomAliasDefaultDomain(String.randomDomain())

        case 3:
            // swiftlint:disable:next force_unwrapping
            return .senderFormat(SenderFormat(rawValue: ["A", "AT", "FULL", "VIA"].randomElement()!)!)

        default: return .notification(Bool.random())
        }
    }
}
