//
//  ContactLite.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 20/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct ContactLite: Decodable {
    let email: String
    let name: String?
    let reverseAlias: String

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case email = "email"
        case name = "name"
        case reverseAlias = "reverse_alias"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decode(String?.self, forKey: .name)
        self.reverseAlias = try container.decode(String.self, forKey: .reverseAlias)
    }
}

extension ContactLite: Equatable {
    static func == (lhs: ContactLite, rhs: ContactLite) -> Bool {
        lhs.email == rhs.email && lhs.name == rhs.name && lhs.reverseAlias == rhs.reverseAlias
    }
}
