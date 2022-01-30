//
//  Preferences.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/08/2021.
//

import SwiftUI

let kDefaultApiUrlString = "https://app.simplelogin.io/"

final class Preferences: ObservableObject {
    private init() {}

    static let shared = Preferences()

    @UserDefault("api_url", defaultValue: kDefaultApiUrlString) var apiUrl: String {
        didSet {
            objectWillChange.send()
        }
    }
}

private extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.io.simplelogin.ios")
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
            UserDefaults.shared?.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.shared?.set(newValue, forKey: key)
        }
    }
}
