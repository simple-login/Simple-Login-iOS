//
//  Message.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Message: Decodable {
    let value: String

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case value = "msg"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(String.self, forKey: .value)
    }
}
