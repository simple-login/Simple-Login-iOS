//
//  MainView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import AlertToast
import LocalAuthentication
import SimpleLoginPackage
import StoreKit
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var reachabilityObserver: ReachabilityObserver
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedItem = TabBarItem.aliases
    @State private var upgradeNeeded = false
    @State private var selectedSheet: Sheet?
    @State private var createdAlias: Alias?
    @AppStorage(kDidShowTips) private var didShowTips = false
    @AppStorage(kLaunchCount) private var launchCount = 0
    @AppStorage(kAliasCreationCount) private var aliasCreationCount = 0
    let onLogOut: () -> Void

    private enum Sheet {
        case tips, createAlias
    }

    var body: some View {
        let showingBiometricAuthFailureAlert = Binding<Bool>(get: {
            viewModel.biometricAuthFailed
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledBiometricAuthFailure()
            }
        })

        let showingSheet = Binding<Bool>(get: {
            selectedSheet != nil
        }, set: { isShowing in
            if !isShowing {
                selectedSheet = nil
            }
        })

        TabView(selection: $selectedItem) {
            AliasesView(session: session,
                        reachabilityObserver: reachabilityObserver,
                        managedObjectContext: managedObjectContext,
                        createdAlias: $createdAlias)
            .tag(TabBarItem.aliases)

            AdvancedView()
                .tag(TabBarItem.advanced)

            AccountView(session: session,
                        upgradeNeeded: $upgradeNeeded,
                        onLogOut: onLogOut)
            .tag(TabBarItem.myAccount)

            SettingsView()
                .tag(TabBarItem.settings)
        }
        .ignoresSafeArea(.keyboard)
        .safeAreaInset(edge: .bottom) {
            MainTabBar(selectedItem: $selectedItem) {
                Vibration.light.vibrate()
                selectedSheet = .createAlias
            }
            // Non-transparent but very pale color to prevent underlying tabs from being tapped
            .background(Color.white.opacity(0.01))
        }
        .emptyPlaceholder(isEmpty: !viewModel.canShowDetails, useZStack: true) {
            ZStack {
                Color(.systemBackground)
                Image(systemName: "lock.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .foregroundColor(.secondary)
                    .opacity(0.1)
            }
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
                    selectedSheet = .tips
                }
            }
            launchCount += 1
        }
        .sheet(isPresented: showingSheet) {
            switch selectedSheet {
            case .tips:
                TipsView(isFirstTime: true)
                    .onAppear {
                        didShowTips = true
                    }
            case .createAlias:
                CreateAliasView(
                    session: session,
                    mode: nil,
                    onCreateAlias: { createdAlias in
                        aliasCreationCount += 1
                        if launchCount >= 10, aliasCreationCount >= 5 {
                            if let scene = UIApplication.shared
                                .connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                switch UIDevice.current.userInterfaceIdiom {
                                case .phone, .pad:
                                    SKStoreReviewController.requestReview(in: scene)
                                default:
                                    break
                                }
                            }
                        }
                        self.createdAlias = createdAlias
                        self.selectedItem = .aliases
                    },
                    onCancel: nil,
                    onOpenMyAccount: {
                        upgradeNeeded = true
                        selectedItem = .myAccount
                    })
            case .none:
                EmptyView()
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
