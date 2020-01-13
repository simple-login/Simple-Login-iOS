//
//  ReverseAlias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct ReverseAlias {
    let name: String
    let destinationEmail: String
    let creationTimestamp: TimeInterval
    
    init() {
        self.destinationEmail = "mail@example.com"
        self.name = "reverse.alias@simplelogin.co"
        self.creationTimestamp = 1578697200
    }
}
