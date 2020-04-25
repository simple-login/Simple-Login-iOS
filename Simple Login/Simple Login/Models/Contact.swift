//
//  Contact.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 14/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class Contact {
    typealias Identifier = Int
    
    let id: Identifier
    let email: String
    let reverseAlias: String
    let creationDate: String
    let creationTimestamp: TimeInterval
    let lastEmailSentDate: String?
    let lastEmailSentTimestamp: TimeInterval?
    
    lazy var creationTimestampString: String = {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let preciseDateAndTime = preciseDateFormatter.string(from: date)
        let (value, unit) =  date.distanceFromNow()
        return "Created on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()
    
    lazy var lastEmailSentTimestampString: String? = {
        guard let lastEmailSentTimestamp = lastEmailSentTimestamp else {
            return nil
        }
        
        let date = Date(timeIntervalSince1970: lastEmailSentTimestamp)
        let preciseDateAndTime = preciseDateFormatter.string(from: date)
        let (value, unit) =  date.distanceFromNow()
        return "Last sent on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()
    
    init(fromDictionary dictionary: [String : Any]) throws {
        let id = dictionary["id"] as? Int
        let email = dictionary["contact"] as? String
        let reverseAlias = dictionary["reverse_alias"] as? String
        let creationDate = dictionary["creation_date"] as? String
        let creationTimestamp = dictionary["creation_timestamp"] as? TimeInterval
        let lastEmailSentDate = dictionary["last_email_sent_date"] as? String
        let lastEmailSentTimestamp = dictionary["last_email_sent_timestamp"] as? TimeInterval
        
        if let id = id, let email = email, let creationDate = creationDate, let creationTimestamp = creationTimestamp, let reverseAlias = reverseAlias {
            self.id = id
            self.email = email
            self.reverseAlias = reverseAlias
            self.creationDate = creationDate
            self.creationTimestamp = creationTimestamp
            self.lastEmailSentDate = lastEmailSentDate
            self.lastEmailSentTimestamp = lastEmailSentTimestamp
        } else {
            throw SLError.failToParseObject(objectName: "Contact")
        }
    }
}
