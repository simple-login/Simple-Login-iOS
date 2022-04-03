//
//  MainView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import AlertToast
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

enum MainViewTab {
    case aliases, advanced, account, about

    var title: String {
        switch self {
        case .aliases: return "Aliases"
        case .advanced: return "Advanced"
        case .account: return "My account"
        case .about: return "About"
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var reachabilityObserver: ReachabilityObserver
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedItem = TabBarItem.aliases
    @State private var showingTips = false
    @State private var upgradeNeeded = false
    @AppStorage(kDidShowTips) private var didShowTips = false
    @AppStorage(kLaunchCount) private var launchCount = 0
    let onLogOut: () -> Void

    var body: some View {
        let showingBiometricAuthFailureAlert = Binding<Bool>(get: {
            viewModel.biometricAuthFailed
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledBiometricAuthFailure()
            }
        })

        VStack(spacing: 0) {
            ZStack {
                AliasesView(session: session,
                            reachabilityObserver: reachabilityObserver,
                            managedObjectContext: managedObjectContext) {
                    upgradeNeeded = true
                    selectedItem = .myAccount
                }
                            .opacity(selectedItem == .aliases ? 1 : 0)

                AdvancedView()
                    .opacity(selectedItem == .advanced ? 1 : 0)

                AccountView(session: session,
                            upgradeNeeded: $upgradeNeeded,
                            onLogOut: onLogOut)
                    .opacity(selectedItem == .myAccount ? 1 : 0)

                AboutView()
                    .opacity(selectedItem == .about ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            MainTabBar(selectedItem: $selectedItem) {
                print("Create")
            }
        }
        .ignoresSafeArea(.keyboard)
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
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .background, newPhase == .inactive {
                viewModel.requestAuthenticationIfNeeded()
            }
        }
        .onAppear {
            if !didShowTips {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingTips = true
                }
            }
            launchCount += 1
        }
        .sheet(isPresented: $showingTips) {
            TipsView(isFirstTime: true)
                .onAppear {
                    didShowTips = true
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
    @AppStorage(kUltraProtectionEnabled) private var ultraProtectionEnabled = false

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

    func requestAuthenticationIfNeeded() {
        canShowDetails = !(biometricAuthEnabled && ultraProtectionEnabled)
    }
}
