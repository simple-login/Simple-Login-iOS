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
    @Environment(\.colorScheme) private var colorScheme
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false
    @AppStorage(kForceDarkMode) private var forceDarkMode = false
    @State private var preferences = Preferences.shared
    @State private var apiKey: ApiKey?
    @State private var client: SLClient?

    var body: some Scene {
        WindowGroup {
            if let apiKey = apiKey, let client = client {
                MainView {
                    try? KeychainService.shared.setApiKey(nil)
                    self.apiKey = nil
                    self.client = nil
                    self.biometricAuthEnabled = false
                    self.forceDarkMode = false
                }
                .accentColor(.slPurple)
                .environmentObject(preferences)
                .environmentObject(Session(apiKey: apiKey, client: client))
                .preferredColorScheme(forceDarkMode ? .dark : colorScheme)
            } else {
                LogInView(apiUrl: preferences.apiUrl) { apiKey, client in
                    try? KeychainService.shared.setApiKey(apiKey)
                    self.apiKey = apiKey
                    self.client = client
                }
                .accentColor(.slPurple)
                .environmentObject(preferences)
                .preferredColorScheme(forceDarkMode ? .dark : colorScheme)
            }
        }
    }
}
