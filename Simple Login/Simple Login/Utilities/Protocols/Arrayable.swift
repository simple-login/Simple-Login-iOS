//
//  Arrayable.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

protocol Arrayable {
    init(dictionary: [String: Any]) throws

    static var jsonRootKey: String { get }
}

extension Array where Element: Arrayable {
    init(data: Data) throws {
        // swiftlint:disable:next line_length
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let dictionaries = jsonDictionary[Element.jsonRootKey] as? [[String: Any]] else {
                throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }

        var elements: [Element] = []
        try dictionaries.forEach { dictionary in
            try elements.append(Element(dictionary: dictionary))
        }

        self = elements
    }
}
