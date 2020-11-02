//
//  Deleted.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Deleted: Decodable {
    let value: Bool

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case value = "deleted"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(Bool.self, forKey: .value)
    }
}
