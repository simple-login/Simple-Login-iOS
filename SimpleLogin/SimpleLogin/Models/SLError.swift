//
//  SLError.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/02/2022.
//

import Foundation

enum SLError: Error {
    case invalidApiUrl
    case missingApiKey
    case contactExists
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidApiUrl:
            return "Invalid API URL"
        case .missingApiKey:
            return "Missing API Key"
        case .contactExists:
            return "Contact already exists"
        case .unknown:
            return "Unknown error"
        }
    }
}
