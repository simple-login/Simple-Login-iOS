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
    
    lazy private(set) var attributedString: NSAttributedString = {
        let premiumOrUpgrade = isPremium ? "Premium" : "Upgrade"
        let plainString = "\(name)\n\(premiumOrUpgrade)"
        
        let attributedString = NSMutableAttributedString(string: plainString)
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: NSMakeRange(0, plainString.count))
        
        if let premiumOrUpgradeRange = plainString.range(of: premiumOrUpgrade) {
            if isPremium {
                attributedString.addAttributes(
                    [.font : UIFont.systemFont(ofSize: 14, weight: .light),
                     .foregroundColor: UIColor.systemGreen], range: NSRange(premiumOrUpgradeRange, in: plainString))
            } else {

                attributedString.addAttributes(
                [.foregroundColor : UIColor.systemBlue,
                 .font : UIFont.systemFont(ofSize: 14, weight: .medium),
                 .underlineStyle : NSUnderlineStyle.single.rawValue,
                 .link : URL(string: "\(BASE_URL)/dashboard/pricing") as Any],
                range: NSRange(premiumOrUpgradeRange, in: plainString))
            }
        }
        
        return attributedString
    }()
    
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
            throw SLError.failToParseUserInfo
        }
    }
}
