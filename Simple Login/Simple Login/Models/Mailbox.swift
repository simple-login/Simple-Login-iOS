//
//  Mailbox.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class Mailbox: Arrayable {
    static var jsonRootKey = "mailboxes"
    
    let id: Int
    let email: String
    private(set) var isDefault: Bool
    let numOfAlias: Int
    let creationTimestamp: TimeInterval
    
    lazy var creationString: String = {
        let (value, unit) =  Date.init(timeIntervalSince1970: creationTimestamp).distanceFromNow()
        return "Created \(value) \(unit) ago"
    }()
    
    lazy var numOfAliasAttributedString: NSAttributedString = {
        let plainString = "\(numOfAlias) \(numOfAlias > 1 ? "aliases" : "alias")"
        let attributedString = NSMutableAttributedString(string: plainString)

        attributedString.addAttributes([
            .foregroundColor: SLColor.titleColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)], range: NSRange(plainString.startIndex..., in: plainString))
        
        if let numOfAliasRange = plainString.range(of: "\(numOfAlias)") {
            attributedString.addAttributes([
            .foregroundColor: SLColor.textColor,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)], range: NSRange(numOfAliasRange, in: plainString))
        }
        
        return attributedString
    }()
    
    init(dictionary: [String: Any]) throws {
        guard let id = dictionary["id"] as? Int,
            let email = dictionary["email"] as? String,
            let isDefault = dictionary["default"] as? Bool,
            let  numOfAlias = dictionary["nb_alias"] as? Int,
            let creationTimestamp = dictionary["creation_timestamp"] as? TimeInterval else {
                throw SLError.failedToParse(anyObject: Self.self)
        }
        
        self.id = id
        self.email = email
        self.isDefault = isDefault
        self.numOfAlias = numOfAlias
        self.creationTimestamp = creationTimestamp
    }
    
    func setIsDefault(_ isDefault: Bool) {
        self.isDefault = isDefault
    }
    
    func toAliasMailbox() -> AliasMailbox {
        return AliasMailbox(id: id, email: email)
    }
}
