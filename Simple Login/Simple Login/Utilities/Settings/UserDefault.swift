//
//  UserDefault.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 31/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

private extension UserDefaults {
    static let shared = {
        return UserDefaults(suiteName: "group.io.simplelogin.ios-app")
    }()
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.shared?.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.shared?.set(newValue, forKey: key)
        }
    }
}
