//
//  UserOptions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Suffix: Equatable {
    let value: [String]

    static func == (lhs: Suffix, rhs: Suffix) -> Bool {
        lhs.value == rhs.value
    }
}

struct UserOptions: Decodable {
    let canCreate: Bool
    let prefixSuggestion: String
    let suffixes: [Suffix]

    lazy var domains: [String] = {
        var domains: [String] = []

        suffixes.forEach { suffix in
            if let domain = RegexHelpers.firstMatch(for: #"(?<=@).*"#, inString: suffix.value[0]) {
                domains.append(domain)
            }
        }

        return domains
    }()

    // swiftlint:disable:next type_name
    private enum Key: String, CodingKey {
        case canCreate = "can_create"
        case prefixSuggestion = "prefix_suggestion"
        case suffixes = "suffixes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.canCreate = try container.decode(Bool.self, forKey: .canCreate)
        self.prefixSuggestion = try container.decode(String.self, forKey: .prefixSuggestion)

        let suffixesArray = try container.decode([[String]].self, forKey: .suffixes)
        self.suffixes = suffixesArray.map { Suffix(value: $0) }
    }
}
