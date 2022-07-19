//
//  SenderFormat.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SenderFormat: String, CustomStringConvertible, Decodable, CaseIterable {
    // swiftlint:disable:next identifier_name
    case at = "AT"
    case a = "A"
    case nameOnly = "NAME_ONLY"
    case atOnly = "AT_ONLY"
    case noName = "NO_NAME"

    var description: String {
        switch self {
        case .at: return "John Doe - john.doe at example.com"
        case .a: return "John Doe - john.doe(a)example.com"
        case .nameOnly: return "John Doe"
        case .atOnly: return "John at example.com"
        case .noName: return "No Name (i.e. only reverse-alias)"
        }
    }
}
