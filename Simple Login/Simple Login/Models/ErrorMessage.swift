//
//  ErrorMessage.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct ErrorMessage {
    let value: String
    
    init(data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
            let error = jsonDictionary["error"] as? String else {
                throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }
        
        self.value = error
    }
}
