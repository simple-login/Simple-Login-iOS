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
            return "Empty clipboard"
        case .invalidApiUrl(let urlString):
            return "Invalid API URL: \(urlString)"
        case .invalidValidationCodeSyntax:
            return "Invalid validation code syntax"
        case .missingApiKey:
            return "Missing API Key"
        case .contactExists:
            return "Contact already exists"
        case .unknown:
            return "Unknown error"
        }
    }
}
