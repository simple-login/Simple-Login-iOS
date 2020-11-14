//
//  DomainLite.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct DomainLite: Decodable {
    let name: String
    let isCustom: Bool

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case name = "domain"
        case isCustom = "is_custom"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.isCustom = try container.decode(Bool.self, forKey: .isCustom)
    }
}
