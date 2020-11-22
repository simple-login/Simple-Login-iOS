//
//  Int+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 03/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension Int {
    static func randomIdentifer() -> Int {
        Int.random(in: 1...100_000)
    }

    static func randomPageId() -> Int {
        Int.random(in: 1...100)
    }

    static func randomStatusCode(except: Int?) -> Int {
        while true {
            let random = Int.random(in: 1...1_000)
            if let except = except, random != except {
                return random
            }
            return random
        }
    }
}
