//
//  UserSettings.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct UserSettings: Decodable {
    let randomMode: RandomMode
    let notification: Bool
    let randomAliasDefaultDomain: String

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case randomMode = "alias_generator"
        case notification = "notification"
        case randomAliasDefaultDomain = "random_alias_default_domain"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.randomMode = try container.decode(RandomMode.self, forKey: .randomMode)
        self.notification = try container.decode(Bool.self, forKey: .notification)
        self.randomAliasDefaultDomain = try container.decode(String.self, forKey: .randomAliasDefaultDomain)
    }
}
