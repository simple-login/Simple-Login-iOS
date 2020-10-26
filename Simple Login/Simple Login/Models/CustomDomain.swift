//
//  CustomDomain.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class CustomDomain {
    let id: Int
    let name: String
    let creationTimestamp: TimeInterval
    let aliasCount: Int
    let isVerified: Bool

    lazy var countAttributedString: NSAttributedString = {
        var plainString = ""
        plainString += "\(aliasCount) "
        plainString += aliasCount > 1 ? "aliases" : "alias"

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

    lazy var creationTimestampString: String = {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "Created on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()

    lazy var catchAllDescriptionString: NSAttributedString = {
        // swiftlint:disable line_length
        let text = """
            This feature allows you to create aliases on the fly. Simply use anything@\(name) next time you need an email address.
            The alias will be created the first time it receives an email.
            """
        // swiftlint:enable line_length
        let attributedString = NSMutableAttributedString(string: text)

        attributedString.addAttributes(
            [.foregroundColor: SLColor.secondaryTitleColor, .font: UIFont.systemFont(ofSize: 14)],
            range: NSRange(text.startIndex..., in: text))

        if let onTheFlyRange = text.range(of: "on the fly") {
            attributedString.addAttribute(.font,
                                          value: UIFont.boldSystemFont(ofSize: 14),
                                          range: NSRange(onTheFlyRange, in: text))
        }

        if let emailRange = text.range(of: "anything@\(name)") {
            attributedString.addAttribute(.backgroundColor,
                                          value: UIColor.systemYellow,
                                          range: NSRange(emailRange, in: text))
            attributedString.addAttribute(.font,
                                          value: UIFont.boldSystemFont(ofSize: 14),
                                          range: NSRange(emailRange, in: text))
        }

        return attributedString
    }()

    init() {
        // swiftlint:disable force_unwrapping
        let randomId = Array(0...100).randomElement()!
        id = randomId
        name = "example\(randomId).com"
        let randomHour = Array(0...10).randomElement()!
        creationTimestamp = TimeInterval(1_578_697_200 + randomHour * 86_400)
        aliasCount = Array(0...100).randomElement()!
        isVerified = Bool.random()
        // swiftlint:enable force_unwrapping
    }
}
