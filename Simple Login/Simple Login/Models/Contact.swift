//
//  Contact.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 14/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Contact: Decodable {
    typealias Identifier = Int

    let id: Identifier
    let email: String
    let reverseAlias: String
    let reverseAliasAddress: String
    let creationDate: String
    let creationTimestamp: TimeInterval
    let lastEmailSentDate: String?
    let lastEmailSentTimestamp: TimeInterval?

    var creationTimestampString: String {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "Created on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }

    var lastEmailSentTimestampString: String? {
        guard let lastEmailSentTimestamp = lastEmailSentTimestamp else {
            return nil
        }

        let date = Date(timeIntervalSince1970: lastEmailSentTimestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "Last sent on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case id = "id"
        case email = "contact"
        case reverseAlias = "reverse_alias"
        case reverseAliasAddress = "reverse_alias_address"
        case creationDate = "creation_date"
        case creationTimestamp = "creation_timestamp"
        case lastEmailSentDate = "last_email_sent_date"
        case lastEmailSentTimestamp = "last_email_sent_timestamp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.reverseAlias = try container.decode(String.self, forKey: .reverseAlias)
        self.reverseAliasAddress = try container.decode(String.self, forKey: .reverseAliasAddress)
        self.creationDate = try container.decode(String.self, forKey: .creationDate)
        self.creationTimestamp = try container.decode(TimeInterval.self, forKey: .creationTimestamp)
        self.lastEmailSentDate = try container.decode(String?.self, forKey: .lastEmailSentDate)
        self.lastEmailSentTimestamp = try container.decode(TimeInterval?.self, forKey: .lastEmailSentTimestamp)
    }
}
