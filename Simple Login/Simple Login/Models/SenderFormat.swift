//
//  SenderFormat.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SenderFormat: String, CustomStringConvertible, Decodable {
    case at = "AT"
    case via = "VIA"
    case a = "A"
    case full = "FULL"

    var description: String {
        switch self {
        case .at: return "John Doe - john.doe at example.com"
        case .via: return "john.doe@example.com via SimpleLogin"
        case .a: return "John Doe - john.doe(a)example.com"
        case .full: return "John Doe - john.doe@example.com"
        }
    }
}
