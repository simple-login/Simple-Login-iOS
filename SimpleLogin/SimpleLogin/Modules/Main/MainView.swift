//
//  MainView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import LocalAuthentication
import AlertToast
import SimpleLoginPackage
import SwiftUI

enum MainViewTab {
    case aliases, others, account, about

    var title: String {
        switch self {
        case .aliases: return "Aliases"
        case .others: return "Others"
        case .account: return "My account"
        case .about: return "About"
        }
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab: MainViewTab = .aliases
    let onLogOut: () -> Void

    var body: some View {
        let showingBiometricAuthFailureAlert = Binding<Bool>(get: {
            viewModel.biometricAuthFailed
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledBiometricAuthFailure()
            }
        })

        TabView(selection: $selectedTab) {
            AliasesView()
                .tabItem {
                    Image(systemName: "at")
                    Text(MainViewTab.aliases.title)
                }
                .tag(MainViewTab.aliases)

            OthersView()
                .tabItem {
                    Image(systemName: selectedTab == .others ? "tray.2.fill" : "tray.2")
                    Text(MainViewTab.others.title)
                }
                .tag(MainViewTab.others)

            AccountView(onLogOut: onLogOut)
                .tabItem {
                    Image(systemName: selectedTab == .account ? "person.fill" : "person")
                    Text(MainViewTab.account.title)
                }
                .tag(MainViewTab.account)

            AboutView()
                .tabItem {
                    Image(systemName: selectedTab == .about ? "info.circle.fill" : "info.circle")
                    Text(MainViewTab.about.title)
                }
                .tag(MainViewTab.about)
        }
        .emptyPlaceholder(isEmpty: !viewModel.canShowDetails) {
            Image(systemName: "lock.circle")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 2)
                .foregroundColor(.secondary)
                .opacity(0.1)
                .onAppear {
                    viewModel.biometricallyAuthenticate()
                }
                .alert(isPresented: showingBiometricAuthFailureAlert) {
                    biometricAuthFailureAlert
                }
        }
    }

    private var biometricAuthFailureAlert: Alert {
        Alert(title: Text("Authentication failed"),
              message: Text("This account is protected, you must authenticate to continue."),
              primaryButton: .default(Text("Try again"), action: viewModel.biometricallyAuthenticate),
              secondaryButton: .destructive(Text("Log out"), action: onLogOut))
    }
}

final class MainViewModel: ObservableObject {
    @Published private(set) var canShowDetails = false
    @Published private(set) var biometricAuthFailed = false
    @AppStorage(kBiometricAuthEnabled) private var biometricAuthEnabled = false

    init() {
        canShowDetails = !biometricAuthEnabled
    }

    func handledBiometricAuthFailure() {
        self.biometricAuthFailed = false
    }

    func biometricallyAuthenticate() {
        let context = LAContext()
        context.localizedFallbackTitle = "Or use your passcode"
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: "Please authenticate") { [weak self] success, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.canShowDetails = true
                } else {
                    self.biometricAuthFailed = true
                }
            }
        }
    }
}
