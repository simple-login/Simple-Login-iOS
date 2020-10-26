//
//  Directory.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class Directory {
    let id: Int
    let name: String
    let creationTimestamp: TimeInterval
    let aliasCount: Int

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

    init() {
        // swiftlint:disable force_unwrapping
        let randomId = Array(0...100).randomElement()!
        id = randomId
        name = "example\(randomId)"
        let randomHour = Array(0...10).randomElement()!
        creationTimestamp = TimeInterval(1_578_697_200 + randomHour * 86_400)
        aliasCount = Array(0...100).randomElement()!
        // swiftlint:enable force_unwrapping
    }
}
