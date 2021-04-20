//
//  AliasActivity.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 06/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct AliasActivity: Decodable {
    let action: Action
    let reverseAlias: String
    let reverseAliasAddress: String
    let from: String
    let to: String
    let timestamp: TimeInterval

    var timestampString: String {
        let date = Date(timeIntervalSince1970: timestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "\(preciseDateAndTime) (\(value) \(unit) ago)"
    }

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case action = "action"
        case reverseAlias = "reverse_alias"
        case reverseAliasAddress = "reverse_alias_address"
        case from = "from"
        case to = "to"
        case timestamp = "timestamp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.action = try container.decode(Action.self, forKey: .action)
        self.reverseAlias = try container.decode(String.self, forKey: .reverseAlias)
        self.reverseAliasAddress = try container.decode(String.self, forKey: .reverseAliasAddress)
        self.from = try container.decode(String.self, forKey: .from)
        self.to = try container.decode(String.self, forKey: .to)
        self.timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
    }
}

extension AliasActivity {
    enum Action: String, Decodable {
        case reply = "reply"
        case block = "block"
        case bounced = "bounced"
        case forward = "forward"
    }
}
