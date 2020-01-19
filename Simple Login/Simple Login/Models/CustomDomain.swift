//
//  CustomDomain.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class CustomDomain {
    let name: String
    let creationTimestamp: TimeInterval
    let aliasCount: Int
    let isVerified: Bool
    
    init() {
        let randomId = Array(0...100).randomElement()!
        name = "example\(randomId).com"
        let randomHour = Array(0...10).randomElement()!
        creationTimestamp = TimeInterval(1578697200 + randomHour * 86400)
        aliasCount = Array(0...100).randomElement()!
        isVerified = Bool.random()
    }
    
    lazy var countAttributedString: NSAttributedString = {
        var plainString = ""
        plainString += "\(aliasCount) "
        plainString += aliasCount > 1 ? "aliases" : "alias"
        
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
}
