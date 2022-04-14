//
//  SuffixExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 14/04/2022.
//

import SimpleLoginPackage

extension Suffix {
    enum DomainType {
        case custom, `public`, premium

        var localizedDescription: String {
            switch self {
            case .custom:
                return "Your domain"
            case .public:
                return "Public domain"
            case .premium:
                return "Premium domain"
            }
        }
    }

    var domainType: DomainType {
        if isCustom { return .custom }
        if isPremium { return .premium }
        return .public
    }
}
