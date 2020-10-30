//
//  DecodableTestCase.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 30/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import XCTest

// swiftlint:disable type_name
protocol DecodableTestCase: class {
    associatedtype T: Decodable

    var dictionary: NSDictionary! { get set }
    var sut: T! { get set }
}

extension DecodableTestCase {
    func givenSutFromJson(fileName: String) throws {
        let decoder = JSONDecoder()
        let data = try Data.fromJson(fileName: fileName)
        dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        sut = try decoder.decode(T.self, from: data)
    }
}
