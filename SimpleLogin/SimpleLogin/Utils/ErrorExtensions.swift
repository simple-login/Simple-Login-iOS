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
            return apiServiceError.description
        case let slClientError as SLClientError:
            return slClientError.localizedDescription
        case let slError as SLError:
            return slError.localizedDescription
        default:
            return localizedDescription
        }
    }
}
