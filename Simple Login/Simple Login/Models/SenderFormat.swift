//
//  SenderFormat.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SenderFormat: String, CustomStringConvertible, Decodable {
    // swiftlint:disable:next identifier_name
    case a = "A"
    case at = "AT"
    case full = "FULL"
    case via = "VIA"

    var description: String {
        switch self {
        case .a: return "John Doe - john.doe(a)example.com"
        case .at: return "John Doe - john.doe at example.com"
        case .full: return "John Doe - john.doe@example.com"
        case .via: return "john.doe@example.com via SimpleLogin"
        }
    }
}
