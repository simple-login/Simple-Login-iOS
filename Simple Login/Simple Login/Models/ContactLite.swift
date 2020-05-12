//
//  ContactLite.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 20/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class ContactLite {
    let email: String
    let name: String?
    let reverseAlias: String
    
    init(fromDictionary dictionary: [String : Any]) throws {
        let email = dictionary["email"] as? String
        let name = dictionary["name"] as? String
        let reverseAlias = dictionary["reverse_alias"] as? String
        
        self.name = name
        if let email = email, let reverseAlias = reverseAlias {
            self.email = email
            self.reverseAlias = reverseAlias
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
