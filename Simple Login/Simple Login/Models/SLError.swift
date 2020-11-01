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
    case failedToGenerateUrlRequest(endpoint: SLEndpoint)
    case invalidApiKey
    case duplicatedAlias
    case duplicatedContact
    case reactivationNeeded
    case internalServerError
    case badGateway
    case badUrlString(urlString: String)
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
        case .failedToGenerateUrlRequest(let endpoint):
            return "Failed to generate url request for endpoint \(endpoint.path)"
        case .invalidApiKey: return "Invalid API key"
        case .duplicatedAlias: return "Alias is duplicated"
        case .duplicatedContact: return "Contact already created"
        case .reactivationNeeded: return "Reactivation needed"
        case .internalServerError: return "Internal server error"
        case .badGateway: return "Bad gateway error"
        case .badUrlString(let urlString): return "Bad url string (\(urlString)"
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

extension SLError: Equatable {
    static func == (lhs: SLError, rhs: SLError) -> Bool {
        switch (lhs, rhs) {
        case let (.failedToSerializeJsonForObject(lhsObject), .failedToSerializeJsonForObject(rhsObject)),
             let (.failedToParse(lhsObject), .failedToParse(rhsObject)),
             let (.failedToDelete(lhsObject), .failedToDelete(rhsObject)):
            return String(describing: type(of: lhsObject)) == String(describing: type(of: rhsObject))

        case let (.failedToGenerateUrlRequest(lhsEndpoint), .failedToGenerateUrlRequest(rhsEndpoint)):
            return lhsEndpoint.path == rhsEndpoint.path

        case (.invalidApiKey, .invalidApiKey),
             (.duplicatedAlias, .duplicatedAlias),
             (.reactivationNeeded, .reactivationNeeded),
             (.internalServerError, .internalServerError),
             (.badGateway, .badGateway):
            return true

        case let (.badUrlString(lhsUrlString), .badUrlString(rhsIUrlString)):
            return lhsUrlString == rhsIUrlString

        case (.wrongTotpToken, .wrongTotpToken),
             (.wrongVerificationCode, .wrongVerificationCode),
             (.unknownResponseStatusCode, .unknownResponseStatusCode):
            return true

        case let (.alamofireError(lhsError), .alamofireError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case let (.badRequest(lhsDescription), .badRequest(rhsDescription)):
            return lhsDescription == rhsDescription

        case let (.unknownErrorWithStatusCode(lhsStatusCode), .unknownErrorWithStatusCode(rhsStatusCode)):
            return lhsStatusCode == rhsStatusCode

        case let (.unknownError(lhsError), .unknownError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        default: return false
        }
    }
}
