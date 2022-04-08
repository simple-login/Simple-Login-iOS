//
//  SettingsView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 08/04/2022.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
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
    }

    private func openAppStore() {
        let urlString = "https://apps.apple.com/app/id1494359858?action=write-review"
        guard let writeReviewURL = URL(string: urlString) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:])
    }
}
