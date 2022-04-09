//
//  SettingsView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 08/04/2022.
//

import AlertToast
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var localAuthenticator = LocalAuthenticator()

    var body: some View {
        NavigationView {
            Form {
                if localAuthenticator.biometryType != .none {
                    BiometricAuthenticationSection()
                        .environmentObject(localAuthenticator)
                }

                Section {
                    Button(action: openAppStore) {
                        Label(title: {
                            Text("Rate & review on App Store")
                                .foregroundColor(Color(.label))
                        }, icon: {
                            Text("🌟")
                        })
                    }

                    NavigationLink(destination: {
                        TipsView(isFirstTime: false)
                    }, label: {
                        Label(title: {
                            Text("Tips")
                        }, icon: {
                            Text("💡")
                        })
                    })
                }

                Section {
                    NavigationLink(destination: {
                        AboutView()
                    }, label: {
                        Label("About SimpleLogin", systemImage: "info.circle")
                    })
                }
            }
                .navigationTitle("Settings")
        }
        .alertToastMessage($localAuthenticator.message)
        .alertToastError($localAuthenticator.error)
    }

    private func openAppStore() {
        let urlString = "https://apps.apple.com/app/id1494359858?action=write-review"
        guard let writeReviewURL = URL(string: urlString) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:])
    }
}

private struct BiometricAuthenticationSection: View {
    @EnvironmentObject private var localAuthenticator: LocalAuthenticator
    @AppStorage(kUltraProtectionEnabled) var ultraProtectionEnabled = false

    var body: some View {
        Section(header: Text("Local authentication"),
                footer: Text("Restrict unwanted access to your SimpleLogin account on this device")) {
            VStack {
                Toggle(isOn: $localAuthenticator.biometricAuthEnabled) {
                    Label(localAuthenticator.biometryType.description,
                          systemImage: localAuthenticator.biometryType.systemImageName)
                }
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                if localAuthenticator.biometricAuthEnabled {
                    Divider()
                    Toggle(isOn: $ultraProtectionEnabled) {
                        Label {
                            Text("Ultra-protection")
                        } icon: {
                            if #available(iOS 15, *) {
                                Image(systemName: "bolt.shield")
                            } else {
                                Image(systemName: "shield")
                            }
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                    Text("Request local authentication everytime the app goes in foreground")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
