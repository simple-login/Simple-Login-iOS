//
//  Mailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Mailbox {
    let id: Int
    let email: String
    let isDefault: Bool
}

extension Mailbox: Arrayable {
    static var jsonRootKey = "mailboxes"
    init(dictionary: [String: Any]) throws {
        guard let id = dictionary["id"] as? Int,
        let email = dictionary["email"] as? String,
            let isDefault = dictionary["default"] as? Bool else {
                throw SLError.failedToParse(anyObject: Self.self)
        }
        
        self.id = id
        self.email = email
        self.isDefault = isDefault
    }
}
