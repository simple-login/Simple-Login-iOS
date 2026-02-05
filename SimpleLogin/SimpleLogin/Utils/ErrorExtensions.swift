//
//  ErrorExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/02/2022.
//

import SimpleLoginPackage

extension Error {
    var safeLocalizedDescription: String {
        switch self {
        case let apiServiceError as APIServiceError:
            apiServiceError.description
        case let slError as SLError:
            slError.localizedDescription
        default:
            localizedDescription
        }
    }
}
