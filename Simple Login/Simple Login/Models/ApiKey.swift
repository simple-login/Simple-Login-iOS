//
//  ApiKey.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 24/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct ApiKey {
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    init(fromData data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }
        
        let value = jsonDictionary["api_key"] as? String
        
        if let value = value {
            self.value = value
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
