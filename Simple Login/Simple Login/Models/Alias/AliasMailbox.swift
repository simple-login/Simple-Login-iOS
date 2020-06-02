//
//  AliasMailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

struct AliasMailbox {
    let id: Int
    let email: String
    
    init(from dictionary: [String: Any]) throws {
        guard let id = dictionary["id"] as? Int,
            let email = dictionary["email"] as? String else {
                throw SLError.failedToParse(anyObject: Self.self)
        }
        
        self.id = id
        self.email = email
    }
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
}

extension Array where Element == AliasMailbox {
    init(from dictionaries: [[String: Any]]) throws {
        var mailboxes: [AliasMailbox] = []
        
        try dictionaries.forEach { dictionary in
            let mailbox = try AliasMailbox(from: dictionary)
            mailboxes.append(mailbox)
        }
        
        self = mailboxes
    }
    
    func toAttributedString(fontSize: CGFloat = 12) -> NSAttributedString {
        let string = map({$0.email}).joined(separator: " & ")
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([
            .foregroundColor: SLColor.tintColor,
            .font: UIFont.systemFont(ofSize: fontSize)
        ],range: NSRange(string.startIndex..., in: string))
        
        forEach({ mailbox in
            if let range = string.range(of: mailbox.email) {
                attributedString.addAttributes([
                    .foregroundColor: SLColor.textColor,
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .medium)
                ],range: NSRange(range, in: string))
            }
        })
        
        return attributedString
    }
}
