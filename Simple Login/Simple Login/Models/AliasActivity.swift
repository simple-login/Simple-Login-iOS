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
    let reverseAlias: String
    let from: String
    let to: String
    let timestamp: TimeInterval
    
    lazy var timestampString: String = {
        let date = Date(timeIntervalSince1970: timestamp)
        let preciseDateAndTime = preciseDateFormatter.string(from: date)
        let (value, unit) =  date.distanceFromNow()
        return "\(preciseDateAndTime) (\(value) \(unit) ago)"
    }()
    
    init(dictionary: [String : Any]) throws {
        var actionString = dictionary["action"] as? String
        if actionString == "blocked" {
            actionString = "block"
        }
        
        let action = Action(rawValue: actionString ?? "")
        
        let reverseAlias = dictionary["reverse_alias"] as? String
        let from = dictionary["from"] as? String
        let to = dictionary["to"] as? String
        let timestamp = dictionary["timestamp"] as? TimeInterval
  
        if let action = action, let reverseAlias = reverseAlias, let from = from, let to = to, let timestamp = timestamp {
            self.action = action
            self.reverseAlias = reverseAlias
            self.from = from
            self.to = to
            self.timestamp = timestamp
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}

extension AliasActivity {
    enum Action: String {
        case reply = "reply"
        case block = "block"
        case bounced = "bounced"
        case forward = "forward"
    }
}

extension Array where Element == AliasActivity {
    init(data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
        let activityDictionaries = jsonDictionary["activities"] as? [[String : Any]] else {
            throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }
        
        var activities: [AliasActivity] = []
        try activityDictionaries.forEach { (dictionary) in
            try activities.append(AliasActivity(dictionary: dictionary))
        }
        
        self = activities
    }
}
