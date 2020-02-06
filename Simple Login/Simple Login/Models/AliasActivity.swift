//
//  AliasActivity.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 06/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class AliasActivity {
    let action: Action
    let from: String
    let to: String
    let timestamp: TimeInterval
    
    lazy var timestampString: String = {
        let date = Date(timeIntervalSince1970: timestamp)
        let preciseDateAndTime = preciseDateFormatter.string(from: date)
        let (value, unit) =  date.distanceFromNow()
        return "\(preciseDateAndTime) (\(value) \(unit) ago)"
    }()
    
    init(fromDictionary dictionary: [String : Any]) throws {
        let actionString = dictionary["action"] as? String
        let action = Action(rawValue: actionString ?? "")
        
        let from = dictionary["from"] as? String
        let to = dictionary["to"] as? String
        let timestamp = dictionary["timestamp"] as? TimeInterval
        
        if let action = action, let from = from, let to = to, let timestamp = timestamp {
            self.action = action
            self.from = from
            self.to = to
            self.timestamp = timestamp
        } else {
            throw SLError.failToParseObject(objectName: "AliasActivity")
        }
    }
}

extension AliasActivity {
    enum Action: String {
        case reply = "reply"
        case block = "block"
        case forward = "forward"
    }
}
