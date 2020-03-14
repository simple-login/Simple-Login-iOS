//
//  UseInfo.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

struct UserInfo {
    let name: String
    let isPremium: Bool
    
    init(fromData data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failToSerializeJSONData
        }
        
        let name = jsonDictionary["name"] as? String
        let isPremium = jsonDictionary["is_premium"] as? Bool
        
        if let name = name, let isPremium = isPremium {
            self.name = name
            self.isPremium = isPremium
        } else {
            throw SLError.failToParseObject(objectName: "UserInfo")
        }
    }
}
