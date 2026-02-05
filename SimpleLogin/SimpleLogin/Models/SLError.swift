//
//  SLError.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/02/2022.
//

import Foundation

enum SLError: Error {
    case emptyClipboard
    case invalidApiUrl(String)
    case invalidValidationCodeSyntax
    case missingApiKey
    case contactExists
    case unknown

    var localizedDescription: String {
        switch self {
        case .emptyClipboard:
            "Empty clipboard"
        case let .invalidApiUrl(urlString):
            "Invalid API URL: \(urlString)"
        case .invalidValidationCodeSyntax:
            "Invalid validation code syntax"
        case .missingApiKey:
            "Missing API Key"
        case .contactExists:
            "Contact already exists"
        case .unknown:
            "Unknown error"
        }
    }
}
