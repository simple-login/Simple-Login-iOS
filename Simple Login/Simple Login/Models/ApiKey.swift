//
//  ApiKey.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 24/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

struct ApiKey: Decodable {
    let value: String

    init(value: String) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.value = try container.decode(String.self, forKey: .apiKey)
    }

    // swiftlint:disable:next type_name
    enum Key: String, CodingKey {
        case apiKey = "api_key"
    }

    // TODO: to be removed
    func toHeaders() -> HTTPHeaders { ["Authentication": value] }
}
