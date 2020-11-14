//
//  Suffix.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Suffix: Decodable {
    let value: String
    let signature: String

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case value = "suffix"
        case signature = "signed_suffix"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.value = try container.decode(String.self, forKey: .value)
        self.signature = try container.decode(String.self, forKey: .signature)
    }

    init(value: String, signature: String) {
        self.value = value
        self.signature = signature
    }
}
