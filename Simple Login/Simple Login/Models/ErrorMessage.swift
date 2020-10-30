//
//  ErrorMessage.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct ErrorMessage: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(String.self, forKey: .error)
    }

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case error = "error"
    }
}
