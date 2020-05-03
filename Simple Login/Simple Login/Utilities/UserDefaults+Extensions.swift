//
//  UserDefaults+Extensions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

fileprivate let defaults = UserDefaults()

extension UserDefaults {
    // MARK: - Review
    private static let numberOfSessionKey = "NumberOfSessionKey"
    static func numberOfSessions() -> Int {
        return defaults.integer(forKey: numberOfSessionKey)
    }
    
    static func increaseNumberOfSessions() {
        let numberOfSessions = defaults.integer(forKey: numberOfSessionKey)
        defaults.set(numberOfSessions + 1, forKey: numberOfSessionKey)
    }
    
    private static let didMakeAReviewKey = "DidMakeAReviewKey"
    static func didMakeAReview() -> Bool {
        return defaults.bool(forKey: didMakeAReviewKey)
    }
    
    static func setDidMakeAReview() {
        defaults.set(true, forKey: didMakeAReviewKey)
    }
}
