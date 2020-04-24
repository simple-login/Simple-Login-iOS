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
    case failToDelete(objectName: String)
    case emailOrPasswordIncorrect
    case invalidApiKey
    case duplicatedAlias
    case duplicatedContact
    case reactivationNeeded
    case internalServerError
    case badGateway
    case wrongTotpToken
    case wrongVerificationCode
    case unknownResponseStatusCode
    case badRequest(description: String)
    case unknownErrorWithStatusCode(statusCode: Int)
    case unknownError(description: String)
    
    var description: String {
        switch self {
        case .noData: return "Server isn't responding. Please try again later."
        case .failToSerializeJSONData: return "Failed to serialize JSON data"
        case .failToParseObject(let objectName): return "Failed to parse \(objectName)"
        case .failToDelete(let objectName): return "Failed to delete \(objectName)"
        case .emailOrPasswordIncorrect: return "Email or password incorrect"
        case .invalidApiKey: return "Invalid API key"
        case .duplicatedAlias: return "Alias is duplicated"
        case .duplicatedContact: return "Contact already created"
        case .reactivationNeeded: return "Reactivation needed"
        case .internalServerError: return "Internal server error"
        case .badGateway: return "Bad gateway error"
        case .wrongTotpToken: return "Wrong TOTP token"
        case .wrongVerificationCode: return "Wrong verification code"
        case .unknownResponseStatusCode: return "Unknown response status code"
        case .badRequest(let description): return "Bad request: \(description)"
        case .unknownErrorWithStatusCode(let statusCode): return "Unknown error with status code \(statusCode)"
        case .unknownError(let description): return "Unknown error: \(description)"
        }
    }
    
    func toParameter() -> [String: Any] {
        return ["error": description]
    }
}
