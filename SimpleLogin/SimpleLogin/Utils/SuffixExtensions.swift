//
//  SuffixExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 14/04/2022.
//

import SimpleLoginPackage
import SwiftUI

extension Suffix {
    enum DomainType {
        case custom, `public`, premium, simpleLogin

        var localizedDescription: String {
            switch self {
            case .custom:
                return "Your domain"
            case .public:
                return "Public domain"
            case .premium:
                return "Premium domain"
            case .simpleLogin:
                return "SimpleLogin domain"
            }
        }
    }

    var domainType: DomainType {
        if isCustom { return .custom }
        if isPremium { return .premium }
        return .public
    }
}

extension Suffix.DomainType {
    var color: Color {
        switch self {
        case .custom:
            return .blue
        case .public:
            return .secondary
        case .premium:
            return .slPurple
        case .simpleLogin:
            return .secondary
        }
    }
}
