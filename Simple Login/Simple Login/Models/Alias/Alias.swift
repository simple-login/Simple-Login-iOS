//
//  Alias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class Alias: Decodable {
    typealias Identifier = Int

    let id: Identifier
    let email: String
    let creationDate: String
    let creationTimestamp: TimeInterval
    let blockCount: Int
    let replyCount: Int
    let forwardCount: Int
    let latestActivity: LatestActivity?
    let isPgpSupported: Bool
    let isPgpDisabled: Bool
    private(set) var mailboxes: [AliasMailbox]
    private(set) var name: String?
    private(set) var note: String?
    private(set) var enabled: Bool

    lazy var creationTimestampString: String = {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "Created on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()

    lazy var countAttributedString: NSAttributedString = {
        var plainString = ""
        plainString += "\(forwardCount) "
        plainString += forwardCount > 1 ? "forwards," : "forward,"

        plainString += " \(blockCount) "
        plainString += blockCount > 1 ? "blocks," : "block,"

        plainString += " \(replyCount) "
        plainString += replyCount > 1 ? "replies" : "reply"

        let attributedString = NSMutableAttributedString(string: plainString)
        attributedString.addAttributes(
            [.foregroundColor: SLColor.titleColor, .font: UIFont.systemFont(ofSize: 12, weight: .medium)],
            range: NSRange(plainString.startIndex..., in: plainString))

        let matchRanges = RegexHelpers.matchRanges(of: "[0-9]{1,}", inString: plainString)
        matchRanges.forEach { range in
            attributedString.addAttributes(
                [
                    .foregroundColor: SLColor.textColor,
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium)
                ],
                range: range)
        }

        return attributedString
    }()

    lazy var creationString: String = {
        let (value, unit) = Date(timeIntervalSince1970: creationTimestamp).distanceFromNow()
        return "Created \(value) \(unit) ago"
    }()

    lazy var latestActivityString: String? = {
        guard let latestActivity = latestActivity else {
            return nil
        }

        let (value, unit) = Date(timeIntervalSince1970: latestActivity.timestamp).distanceFromNow()
        return "\(latestActivity.contact.email) • \(value) \(unit) ago"
    }()

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case id = "id"
        case email = "email"
        case creationDate = "creation_date"
        case creationTimestamp = "creation_timestamp"
        case blockCount = "nb_block"
        case replyCount = "nb_reply"
        case forwardCount = "nb_forward"
        case latestActivity = "latest_activity"
        case isPgpSupported = "support_pgp"
        case isPgpDisabled = "disable_pgp"
        case mailboxes = "mailboxes"
        case name = "name"
        case note = "note"
        case enabled = "enabled"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.creationDate = try container.decode(String.self, forKey: .creationDate)
        self.creationTimestamp = try container.decode(TimeInterval.self, forKey: .creationTimestamp)
        self.blockCount = try container.decode(Int.self, forKey: .blockCount)
        self.replyCount = try container.decode(Int.self, forKey: .replyCount)
        self.forwardCount = try container.decode(Int.self, forKey: .forwardCount)
        self.latestActivity = try container.decode(LatestActivity?.self, forKey: .latestActivity)
        self.isPgpSupported = try container.decode(Bool.self, forKey: .isPgpSupported)
        self.isPgpDisabled = try container.decode(Bool.self, forKey: .isPgpDisabled)
        self.mailboxes = try container.decode([AliasMailbox].self, forKey: .mailboxes)
        self.name = try container.decode(String?.self, forKey: .name)
        self.note = try container.decode(String?.self, forKey: .note)
        self.enabled = try container.decode(Bool.self, forKey: .enabled)
    }
}

extension Alias: Equatable {
    static func == (lhs: Alias, rhs: Alias) -> Bool { lhs.id == rhs.id }
}

// MARK: - Setters
extension Alias {
    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }

    func setMailboxes(_ mailboxes: [AliasMailbox]) {
        self.mailboxes = mailboxes
    }

    func setNote(_ note: String?) {
        self.note = note
    }

    func setName(_ name: String?) {
        self.name = name
    }
}
