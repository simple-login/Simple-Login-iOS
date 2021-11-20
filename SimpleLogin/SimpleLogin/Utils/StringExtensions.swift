//
//  StringExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
            .evaluate(with: self)
    }

    var isValidPrefix: Bool {
        guard 1...100 ~= self.count else { return false }
        return NSPredicate(format: "SELF MATCHES %@", "[0-9a-z-_.]+")
            .evaluate(with: self)
    }
}
