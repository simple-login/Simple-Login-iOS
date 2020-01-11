//
//  Alias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class Alias {
    let name: String
    let forwardCount: Int
    let blockCount: Int
    let replyCount: Int
    private(set) var isEnabled: Bool
    let creationTimestamp: TimeInterval
    
    init() {
        name = "random@simplelogin.co"
        forwardCount = 1
        blockCount = 2
        replyCount = 3
        isEnabled = Bool.random()
        creationTimestamp = 1578697200
    }
    
    func toggleIsEnabled() {
        isEnabled.toggle()
    }
}
