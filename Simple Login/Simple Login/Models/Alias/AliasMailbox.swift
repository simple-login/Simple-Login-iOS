//
//  AliasMailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

struct AliasMailbox: Decodable {
    let id: Int
    let email: String

    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
}

extension AliasMailbox: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.email < rhs.email }
}

extension Array where Element == AliasMailbox {
    func toAttributedString(fontSize: CGFloat = 12) -> NSAttributedString {
        let sortedArray = sorted()
        let string = sortedArray.map { $0.email }.joined(separator: " & ")
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes(
            [.foregroundColor: SLColor.tintColor, .font: UIFont.systemFont(ofSize: fontSize)],
            range: NSRange(string.startIndex..., in: string))

        sortedArray.forEach { mailbox in
            if let range = string.range(of: mailbox.email) {
                // swiftlint:disable line_length
                attributedString.addAttributes(
                    [.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: fontSize, weight: .medium)],
                    range: NSRange(range, in: string))
                // swiftline:enable line_length
            }
        }

        return attributedString
    }
}
