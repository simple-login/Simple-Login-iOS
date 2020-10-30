//
//  UseInfo.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

struct UserInfo: Decodable {
    let name: String
    let email: String
    let profilePictureUrl: String?
    let isPremium: Bool
    let inTrial: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.profilePictureUrl = try container.decode(String?.self, forKey: .profilePictureUrl)
        self.isPremium = try container.decode(Bool.self, forKey: .isPremium)
        self.inTrial = try container.decode(Bool.self, forKey: .inTrial)
    }

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case name = "name"
        case email = "email"
        case profilePictureUrl = "profile_picture_url"
        case isPremium = "is_premium"
        case inTrial = "in_trial"
    }
}
