//
//  UserDefaults+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

fileprivate let defaults = UserDefaults()

extension UserDefaults {
    // MARK: - Init default values
    static func registerDefaultValues() {
        defaults.register(defaults: [isFirstRunKey : true, shownInstructionKey : false])
    }
    
    // MARK: - First run
    private static let isFirstRunKey = "IsFirstRun"
    
    static func isFirstRun() -> Bool {
        return defaults.bool(forKey: isFirstRunKey)
    }
    
    static func firstRunComplete() {
        defaults.set(false, forKey: isFirstRunKey)
    }
    
    // MARK: - Show instruction
    private static let shownInstructionKey = "ShownInstruction"
    
    static func shownInstruction() -> Bool {
        return defaults.bool(forKey: shownInstructionKey)
    }
    
    static func showInstructionComplete() {
        defaults.set(true, forKey: shownInstructionKey)
    }
}
