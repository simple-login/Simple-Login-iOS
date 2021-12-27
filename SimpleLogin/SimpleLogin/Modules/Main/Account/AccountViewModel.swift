//
//  AccountViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

let kBiometricAuthEnabled = "BiometricAuthEnabled"

final class AccountViewModel: ObservableObject {
    private(set) var userInfo: UserInfo = .empty
    private(set) var usableDomains: [UsableDomain] = []
    private var lastKnownUserSettings: UserSettings?
    @Published var notification = false
    @Published var randomMode: RandomMode = .uuid
    @Published var randomAliasDefaultDomain = ""
    @Published var senderFormat: SenderFormat = .a
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var error: SLClientError?
    @Published private(set) var isInitialized = false
    @Published private(set) var isLoading = false
    @Published private(set) var message: String?
    @Published private(set) var isBiometricallyAuthenticating = false
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false {
        didSet {
            biometricallyAuthenticate()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private var session: Session?

    init() {
        let localAuthenticationContext = LAContext()
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            biometryType = localAuthenticationContext.biometryType
        }

        let shouldUpdateUserSettings: () -> Bool = { [unowned self] in
            self.isInitialized && self.error == nil
        }

        $notification
            .sink { [weak self] selectedNotification in
                guard let self = self else { return }
                if shouldUpdateUserSettings(), selectedNotification != self.notification {
                    self.update(option: .notification(selectedNotification))
                }
            }
            .store(in: &cancellables)

        $randomMode
            .sink { [weak self] selectedRandomMode in
                guard let self = self else { return }
                if shouldUpdateUserSettings(), selectedRandomMode != self.randomMode {
                    self.update(option: .randomMode(selectedRandomMode))
                }
            }
            .store(in: &cancellables)

        $randomAliasDefaultDomain
            .sink { [weak self] selectedRandomAliasDefaultDomain in
                guard let self = self else { return }
                if shouldUpdateUserSettings(), selectedRandomAliasDefaultDomain != self.randomAliasDefaultDomain {
                    self.update(option: .randomAliasDefaultDomain(selectedRandomAliasDefaultDomain))
                }
            }
            .store(in: &cancellables)

        $senderFormat
            .sink { [weak self] selectedSenderFormat in
                guard let self = self else { return }
                if shouldUpdateUserSettings(), selectedSenderFormat != self.senderFormat {
                    self.update(option: .senderFormat(selectedSenderFormat))
                }
            }
            .store(in: &cancellables)
    }

    func setSession(_ session: Session) {
        self.session = session
    }

    func handledError() {
        self.error = nil
    }

    func handledMessage() {
        self.message = nil
    }

    func getRequiredInformation() {
        guard let session = session else { return }
        guard !isLoading && !isInitialized else { return }
        isLoading = true
        let getUserInfo = session.client.getUserInfo(apiKey: session.apiKey)
        let getUserSettings = session.client.getUserSettings(apiKey: session.apiKey)
        let getUsableDomains = session.client.getUsableDomains(apiKey: session.apiKey)
        Publishers.Zip3(getUserInfo, getUserSettings, getUsableDomains)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: self.isInitialized = true
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.userInfo = result.0
                self.bind(userSettings: result.1)
                self.usableDomains = result.2
            }
            .store(in: &cancellables)
    }

    private func update(option: UserSettingsUpdateOption) {
        guard let session = session else { return }
        guard !isLoading else { return }
        isLoading = true
        session.client.updateUserSettings(apiKey: session.apiKey, option: option)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.error = error
                    if let lastKnownUserSettings = self.lastKnownUserSettings {
                        self.bind(userSettings: lastKnownUserSettings)
                    }
                }
            } receiveValue: { [weak self] userSettings in
                guard let self = self else { return }
                self.bind(userSettings: userSettings)
            }
            .store(in: &cancellables)
    }

    private func bind(userSettings: UserSettings) {
        self.notification = userSettings.notification
        self.randomMode = userSettings.randomMode
        self.randomAliasDefaultDomain = userSettings.randomAliasDefaultDomain
        self.senderFormat = userSettings.senderFormat
        self.lastKnownUserSettings = userSettings
    }

    private func biometricallyAuthenticate() {
        guard !isBiometricallyAuthenticating else { return }
        isBiometricallyAuthenticating = true
        let context = LAContext()
        context.localizedFallbackTitle = "Or use your passcode"
        let reason = biometricAuthEnabled ?
        "Please authenticate to activate \(biometryType.description)" :
        "Please authenticate to deactivate \(biometryType.description)"
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: reason) { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer {
                    self.isBiometricallyAuthenticating = false
                }
                if success {
                    self.message = self.biometricAuthEnabled ?
                    "\(self.biometryType.description) activated" :
                    "\(self.biometryType.description) deactivated"
                    return
                }

                if let error = error {
                    self.error = .other(error)
                } else {
                    self.error = .unknown(statusCode: 999)
                }
                self.biometricAuthEnabled.toggle()
            }
        }
    }
}

extension LABiometryType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "Biometric authentication not supported"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        @unknown default: return "Unknown biometric type"
        }
    }

    var systemImageName: String {
        switch self {
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        default: return ""
        }
    }
}

extension UserInfo {
    static var empty: UserInfo {
        UserInfo(name: "", email: "", profilePictureUrl: nil, isPremium: false, inTrial: false)
    }
}

extension RandomMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .uuid: return "UUID"
        case .word: return "Random words"
        }
    }
}
