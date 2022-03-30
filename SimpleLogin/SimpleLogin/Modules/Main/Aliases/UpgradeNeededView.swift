//
//  UpgradeNeededView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 29/03/2022.
//

import SwiftUI

struct UpgradeNeededView: View {
    @State private var showingAlert = false
    let onOk: (() -> Void)?
    let onOpenMyAccount: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("LogoWithoutName")
                .resizable()
                .scaledToFit()
                .frame(width: min(200, UIScreen.main.minLength / 3))

            Text("You've reached the limit of free aliases. Become premium user to gain access to all of our features.")
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(kPremiumCapacities) {
                    CapacityView(capacity: $0, checkmarkColor: .slPurple)
                }
                Text("...and all of our upcoming features.")
            }

            Spacer()

            PrimaryButton(title: "Upgrade now") {
                if Bundle.main.bundleURL.pathExtension == "appex" {
                    showingAlert = true
                } else {
                    onOpenMyAccount?()
                }
            }
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Upgrade now"),
                  message: Text("Open SimpleLogin application ➝ My account ➝ Upgrade"),
                  dismissButton: .default(Text("OK")) { onOk?() })
        }
        .onAppear {
            UIView.appearance(whenContainedInInstancesOf:
                                [UIAlertController.self]).tintColor = .slPurple
        }
    }
}

private let kPremiumCapacities: [Capacity] = [
    .unlimitedAliases,
    .unlimitedMailboxes,
    .unlimitedDomains,
    .catchAllDomain,
    .fiveSubdomains,
    .fiftyDirectories,
    .pgp
]
