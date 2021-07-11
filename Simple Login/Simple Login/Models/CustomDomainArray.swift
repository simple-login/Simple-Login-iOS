//
//  CustomDomainArray.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/03/2021.
//  Copyright © 2021 SimpleLogin. All rights reserved.
//

import Foundation

struct CustomDomainArray: Decodable {
    let customDomains: [CustomDomain]

    // swiftlint:disable type_name
    private enum Key: String, CodingKey {
        case customDomains = "custom_domains"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.customDomains = try container.decode([CustomDomain].self, forKey: .customDomains)
    }
}
