//
//  String+Utilities.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension String {
    func isValidEmailPrefix() -> Bool {
        if let _ = RegexHelpers.firstMatch(for: #"([^0-9|A-Z|a-z|\-|_])"#, inString: self) {
            return false
        }
        
        if count > ALIAS_PREFIX_MAX_LENGTH || count == 0 { return false }
        
        return true
    }
}
