//
//  AliasMailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

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
}
