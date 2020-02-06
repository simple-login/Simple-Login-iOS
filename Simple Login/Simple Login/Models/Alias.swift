//
//  Alias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class Alias: Equatable {
    let id: Int
    let email: String
    let creationDate: String
    let creationTimestamp: TimeInterval
    let blockCount: Int
    let replyCount: Int
    let forwardCount: Int
    let enabled: Bool
    
    lazy var countAttributedString: NSAttributedString = {
        var plainString = ""
        plainString += " \(forwardCount) "
        plainString += forwardCount > 1 ? "forwards," : "forward,"
        
        plainString += " \(blockCount) "
        plainString += blockCount > 1 ? "blocks," : "block,"
        
        plainString += " \(replyCount) "
        plainString += replyCount > 1 ? "replies" : "reply"
        
        let attributedString = NSMutableAttributedString(string: plainString)
        attributedString.addAttributes([
            .foregroundColor: SLColor.titleColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)], range: NSRange(plainString.startIndex..., in: plainString))
        
        let matchRanges = RegexHelpers.matchRanges(of: "[0-9]{1,}", inString: plainString)
        matchRanges.forEach { (range) in
            attributedString.addAttributes([
            .foregroundColor: SLColor.textColor,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)], range: range)
        }
        
        return attributedString
    }()
    
    lazy var creationString: String = {
        let (value, unit) =  Date.init(timeIntervalSince1970: creationTimestamp).distanceFromNow()
        return "Created \(value) \(unit) ago"
    }()
    
    init(fromDictionary dictionary: [String : Any]) throws {
        let id = dictionary["id"] as? Int
        let email = dictionary["email"] as? String
        let creationDate = dictionary["creation_date"] as? String
        let creationTimestamp = dictionary["creation_timestamp"] as? TimeInterval
        let blockCount = dictionary["nb_block"] as? Int
        let forwardCount = dictionary["nb_forward"] as? Int
        let replyCount = dictionary["nb_reply"] as? Int
        
        if let id = id, let email = email, let creationDate = creationDate, let creationTimestamp = creationTimestamp, let blockCount = blockCount, let forwardCount = forwardCount, let replyCount = replyCount {
            self.id = id
            self.email = email
            self.creationDate = creationDate
            self.creationTimestamp = creationTimestamp
            self.blockCount = blockCount
            self.forwardCount = forwardCount
            self.replyCount = replyCount
            self.enabled = Bool.random()
        } else {
            throw SLError.failToParseObject(objectName: "Alias")
        }
    }
    
    static func ==(lhs: Alias, rhs: Alias) -> Bool {
        return lhs.id == rhs.id
    }
}
