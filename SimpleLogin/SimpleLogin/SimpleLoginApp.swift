//
//  SimpleLoginApp.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/06/2021.
//

import SwiftUI

@main
struct SimpleLoginApp: App {
    @State private var preferences = Preferences.shared
    var body: some Scene {
        WindowGroup {
            LogInView()
                .loadableToastable()
                .environmentObject(preferences)
        }
    }
}
