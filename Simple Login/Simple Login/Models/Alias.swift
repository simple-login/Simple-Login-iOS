//
//  Alias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class Alias: Equatable {
    let name: String
    let forwardCount: Int
    let blockCount: Int
    let replyCount: Int
    private(set) var isEnabled: Bool
    let creationTimestamp: TimeInterval
    
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
    
    init() {
        let randomId = Array(0...100).randomElement()!
        name = "random\(randomId)@simplelogin.co"
        forwardCount = Array(0...10).randomElement()!
        blockCount = Array(0...10).randomElement()!
        replyCount = Array(0...10).randomElement()!
        isEnabled = Bool.random()
        let randomHour = Array(0...10).randomElement()!
        creationTimestamp = TimeInterval(1578697200 + randomHour * 86400)
    }
    
    func toggleIsEnabled() {
        isEnabled.toggle()
    }
    
    static func ==(lhs: Alias, rhs: Alias) -> Bool {
        return lhs.name == rhs.name
    }
}
