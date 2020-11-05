//
//  SLError.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SLError: Error, CustomStringConvertible {
    case reactivationNeeded
    case internalServerError
    case badGateway
    case badUrlString(urlString: String)
    case unknownResponseStatusCode
    case badRequest(description: String)
    case unknownErrorWithStatusCode(statusCode: Int)
    case unknownError(error: Error)

    var description: String {
        switch self {
        case .reactivationNeeded: return "Reactivation needed"
        case .internalServerError: return "Internal server error"
        case .badGateway: return "Bad gateway error"
        case .badUrlString(let urlString): return "Bad url string (\(urlString)"
        case .unknownResponseStatusCode: return "Unknown response status code"
        case .badRequest(let description): return description
        case .unknownErrorWithStatusCode(let statusCode):
            return "Unknown error with status code \(statusCode)"
        case .unknownError(let error): return "Unknown error: \(error.localizedDescription)"
        }
    }
}

extension SLError: Equatable {
    static func == (lhs: SLError, rhs: SLError) -> Bool {
        switch (lhs, rhs) {
        case (.reactivationNeeded, .reactivationNeeded),
             (.internalServerError, .internalServerError),
             (.badGateway, .badGateway):
            return true

        case let (.badUrlString(lhsUrlString), .badUrlString(rhsIUrlString)):
            return lhsUrlString == rhsIUrlString

        case (.unknownResponseStatusCode, .unknownResponseStatusCode):
            return true

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
