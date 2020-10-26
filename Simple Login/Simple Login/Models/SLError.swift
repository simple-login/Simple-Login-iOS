//
//  SLError.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

enum SLError: Error, CustomStringConvertible {
    case failedToSerializeJsonForObject(anyObject: Any)
    case failedToParse(anyObject: Any)
    case failedToDelete(anyObject: Any)
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
    case alamofireError(error: AFError)
    case badRequest(description: String)
    case unknownErrorWithStatusCode(statusCode: Int)
    case unknownError(error: Error)

    var description: String {
        switch self {
        case .failedToSerializeJsonForObject(let anyObject):
            return "Failed to serialize JSON for object \(anyObject.self)"
        case .failedToParse(let anyObject): return "Failed to parse \(anyObject.self)"
        case .failedToDelete(let anyObject): return "Failed to delete \(anyObject.self)"
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
        case .alamofireError(let error): return error.localizedDescription
        case .badRequest(let description): return description
        case .unknownErrorWithStatusCode(let statusCode):
            return "Unknown error with status code \(statusCode)"
        case .unknownError(let error): return "Unknown error: \(error.localizedDescription)"
        }
    }

    func toParameter() -> [String: Any] { ["error": description] }
}
