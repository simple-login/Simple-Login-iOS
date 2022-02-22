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
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false
    @AppStorage(kUltraProtectionEnabled) var ultraProtectionEnabled = false
    @AppStorage(kForceDarkMode) private var forceDarkMode = false
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default
    @AppStorage(kDidShowTips) private var didShowTips = false
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
                    self.ultraProtectionEnabled = false
                    self.forceDarkMode = false
                    self.displayMode = .default
                    self.didShowTips = false
                }
                .accentColor(.slPurple)
                .environmentObject(preferences)
                .environmentObject(Session(apiKey: apiKey, client: client))
                .sensitiveContent {
                    ZStack {
                        Color(.systemBackground)
                        Image("LogoWithName")
                    }
                }
            } else {
                LogInView(apiUrl: preferences.apiUrl) { apiKey, client in
                    try? KeychainService.shared.setApiKey(apiKey)
                    self.apiKey = apiKey
                    self.client = client
                }
                .accentColor(.slPurple)
                .environmentObject(preferences)
            }
        }
        .onChange(of: scenePhase) { _ in
            if forceDarkMode {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            }
        }
    }
}
