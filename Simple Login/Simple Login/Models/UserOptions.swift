//
//  UserOptions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct Suffix {
    let value: [String]
}

struct UserOptions {
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

    /*
     {
         "can_create": true,
         "prefix_suggestion": "",
         "suffixes": [
             [
                 ".claustrum@sldev.ovh",
                 ".claustrum@sldev.ovh.XtTG1w.N_0x77e2dOYlCklEM1RaOp0q3Fc"
             ],
             [
                 ".cellulosing@hai.sldev.ovh",
                 ".cellulosing@hai.sldev.ovh.XtTG1w.dY3zGAGRU9MV7LhBKVMfgFEWNrA"
             ]
         ]
     }
     */

    init(data: Data) throws {
        // swiftlint:disable:next line_length
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }

        let canCreate = jsonDictionary["can_create"] as? Bool
        let prefixSuggestion = jsonDictionary["prefix_suggestion"] as? String
        let suffixes = jsonDictionary["suffixes"] as? [[String]]

        if let canCreate = canCreate,
            let prefixSuggestion = prefixSuggestion,
            let suffixes = suffixes {
            self.canCreate = canCreate
            self.prefixSuggestion = prefixSuggestion
            self.suffixes = suffixes.map { Suffix(value: $0) }
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
