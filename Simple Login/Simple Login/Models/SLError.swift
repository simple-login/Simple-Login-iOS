//
//  SLError.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SLError: Error, CustomStringConvertible {
    case noData
    case failToSerializeJSONData
    case failToParseUserInfo
    case failToParseUserOptions
    case invalidApiKey
    case duplicatedAlias
    case unknownError(description: String)
    
    var description: String {
        switch self {
        case .noData: return "Server returns no data"
        case .failToSerializeJSONData: return "Failed to serialize JSON data"
        case .failToParseUserInfo: return "Failed to parse user's info"
        case .failToParseUserOptions: return "Failed to parse user's options"
        case .invalidApiKey: return "Invalid API key"
        case .duplicatedAlias: return "Alias is duplicated"
        case .unknownError(let description): return "Unknown error: \(description)"
        }
    }
}
