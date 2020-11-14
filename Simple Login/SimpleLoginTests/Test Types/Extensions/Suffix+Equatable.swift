//
//  Suffix+Equatable.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin

extension Suffix: Equatable {
    public static func == (lhs: Suffix, rhs: Suffix) -> Bool {
        lhs.value == rhs.value && lhs.signature == rhs.signature
    }
}
