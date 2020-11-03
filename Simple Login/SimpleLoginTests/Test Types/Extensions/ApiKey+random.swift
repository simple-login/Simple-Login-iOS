//
//  ApiKey+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 03/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin

extension ApiKey {
    static func random() -> ApiKey {
        ApiKey(value: String.random(allowedLetters: .lowercase, length: 60))
    }
}
