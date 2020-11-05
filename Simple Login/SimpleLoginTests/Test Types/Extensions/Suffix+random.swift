//
//  Suffix+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 05/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin

extension Suffix {
    static func random() -> Suffix {
        Suffix(value: [String.randomName(), String.randomName()])
    }
}
