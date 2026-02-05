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
                "Your domain"
            case .public:
                "Public domain"
            case .premium:
                "Premium domain"
            case .simpleLogin:
                "SimpleLogin domain"
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
            .blue
        case .public:
            .secondary
        case .premium:
            .slPurple
        case .simpleLogin:
            .secondary
        }
    }
}
