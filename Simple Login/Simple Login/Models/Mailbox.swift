//
//  Mailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class Mailbox: Decodable {
    let id: Int
    let email: String
    private(set) var isDefault: Bool
    let numOfAlias: Int
    let creationTimestamp: TimeInterval
    let isVerified: Bool

    // TODO: to be removed
    lazy var creationString: String = {
        let (value, unit) = Date(timeIntervalSince1970: creationTimestamp).distanceFromNow()
        return "Created \(value) \(unit) ago"
    }()

    // TODO: to be removed
    lazy var numOfAliasAttributedString: NSAttributedString = {
        let plainString = "\(numOfAlias) \(numOfAlias > 1 ? "aliases" : "alias")"
        let attributedString = NSMutableAttributedString(string: plainString)

        attributedString.addAttributes(
            [.foregroundColor: SLColor.titleColor, .font: UIFont.systemFont(ofSize: 12, weight: .medium)],
            range: NSRange(plainString.startIndex..., in: plainString))

        if let numOfAliasRange = plainString.range(of: "\(numOfAlias)") {
            attributedString.addAttributes(
                [.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: 13, weight: .medium)],
                range: NSRange(numOfAliasRange, in: plainString))
        }

        return attributedString
    }()

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case id = "id"
        case email = "email"
        case isDefault = "default"
        case numOfAlias = "nb_alias"
        case creationTimestamp = "creation_timestamp"
        case isVerified = "verified"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.isDefault = try container.decode(Bool.self, forKey: .isDefault)
        self.numOfAlias = try container.decode(Int.self, forKey: .numOfAlias)
        self.creationTimestamp = try container.decode(TimeInterval.self, forKey: .creationTimestamp)
        self.isVerified = try container.decode(Bool.self, forKey: .isVerified)
    }

    func setIsDefault(_ isDefault: Bool) {
        self.isDefault = isDefault
    }

    func toAliasMailbox() -> AliasMailbox { AliasMailbox(id: id, email: email) }
}
