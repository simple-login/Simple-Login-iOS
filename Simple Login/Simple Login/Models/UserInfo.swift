//
//  UseInfo.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class UserInfo {
    let name: String
    let email: String
    private(set) var isPremium: Bool
    let inTrial: Bool
    
    init(data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failToSerializeJSONData
        }
        
        let name = jsonDictionary["name"] as? String
        let email = jsonDictionary["email"] as? String
        let isPremium = jsonDictionary["is_premium"] as? Bool
        let inTrial = jsonDictionary["in_trial"] as? Bool
        
        if let name = name, let email = email, let isPremium = isPremium, let inTrial = inTrial {
            self.name = name
            self.email = email
            self.isPremium = isPremium
            self.inTrial = inTrial
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
    
    func setIsPremium(_ isPremium: Bool) {
        self.isPremium = isPremium
    }
}
