//
//  SimpleLoginApp.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/06/2021.
//

import SimpleLoginPackage
import SwiftUI

@main
struct SimpleLoginApp: App {
    @State private var preferences = Preferences.shared
    @State private var apiKey: ApiKey?

    var body: some Scene {
        WindowGroup {
            if let apiKey = apiKey {
                MainView(apiKey: apiKey)
                    .environmentObject(preferences)
                    .animation(.default)
                    .transition(.opacity)
            } else {
                LogInView { apiKey in
                    self.apiKey = apiKey
                }
                .loadableToastable()
                .environmentObject(preferences)
                .animation(.default)
                .transition(.opacity)
            }
        }
    }
}
