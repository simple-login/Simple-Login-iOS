//
//  LatestActivity.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 20/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class LatestActivity {
    let action: AliasActivity.Action
    let contact: ContactLite
    let timestamp: TimeInterval
    
    init(fromDictionary dictionary: [String : Any]) throws {
        var actionString = dictionary["action"] as? String
        if actionString == "blocked" {
            actionString = "block"
        }
        
        let action = AliasActivity.Action(rawValue: actionString ?? "")
        let contactDictionary = dictionary["contact"] as? [String: Any]
        let timestamp = dictionary["timestamp"] as? TimeInterval
        
        if let action = action, let contactDictionary = contactDictionary, let timestamp = timestamp {
            self.action = action
            self.contact = try ContactLite(fromDictionary: contactDictionary)
            self.timestamp = timestamp
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
