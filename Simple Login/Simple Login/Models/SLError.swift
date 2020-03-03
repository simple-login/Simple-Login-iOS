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
    case failToParseObject(objectName: String)
    case emailOrPasswordIncorrect
    case invalidApiKey
    case duplicatedAlias
    case reactivationNeeded
    case badRequest(description: String)
    case unknownError(description: String)
    
    var description: String {
        switch self {
        case .noData: return "Server returns no data"
        case .failToSerializeJSONData: return "Failed to serialize JSON data"
        case .failToParseObject(let objectName): return "Failed to parse \(objectName)"
        case .emailOrPasswordIncorrect: return "Email or password incorrect"
        case .invalidApiKey: return "Invalid API key"
        case .duplicatedAlias: return "Alias is duplicated"
        case .reactivationNeeded: return "Reactivation needed"
        case .badRequest(let description): return "Bad request: \(description)"
        case .unknownError(let description): return "Unknown error: \(description)"
        }
    }
}
