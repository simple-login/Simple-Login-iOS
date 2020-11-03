//
//  Ok.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 02/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
/**
 Hold response from server in cases like update alias's mailboxes
 */
struct Ok: Decodable {
    let value: Bool

    private enum Key: String, CodingKey {
        case value = "ok"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.value = try container.decode(Bool.self, forKey: .value)
    }
}
