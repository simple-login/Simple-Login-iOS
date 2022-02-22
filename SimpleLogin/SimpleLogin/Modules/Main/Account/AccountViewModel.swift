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

final class AccountViewModel: BaseSessionViewModel, ObservableObject {
    @Published private(set) var userInfo: UserInfo = .empty
    private(set) var usableDomains: [UsableDomain] = []
    private var lastKnownUserSettings: UserSettings?
    @Published var notification = false
    @Published var randomMode: RandomMode = .uuid
    @Published var randomAliasDefaultDomain = ""
    @Published var senderFormat: SenderFormat = .a
    @Published var randomAliasSuffix: RandomAliasSuffix = .word
    @Published var askingForSettings = false
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var error: Error?
    @Published private(set) var isInitialized = false
    @Published private(set) var isLoading = false
    @Published private(set) var message: String?
    @Published private(set) var isBiometricallyAuthenticating = false
    @Published private(set) var shouldLogOut = false
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false {
        didSet {
            biometricallyAuthenticate()
        }
    }
    @AppStorage(kUltraProtectionEnabled) var ultraProtectionEnabled = false
    @AppStorage(kAliasDisplayMode) var aliasDisplayMode: AliasDisplayMode = .default
    private var cancellables = Set<AnyCancellable>()

    override init(session: Session) {
        super.init(session: session)
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

        $randomAliasSuffix
            .sink { [weak self] selectedRandomAliasSuffix in
                guard let self = self else { return }
                if shouldUpdateUserSettings(), selectedRandomAliasSuffix != self.randomAliasSuffix {
                    self.update(option: .randomAliasSuffix(selectedRandomAliasSuffix))
                }
            }
            .store(in: &cancellables)
    }

    func handledError() {
        self.error = nil
    }

    func handledMessage() {
        self.message = nil
    }

    func getRequiredInformation() {
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
                case .failure(let error):
                    if let slClientEror = error as? SLClientError {
                        switch slClientEror {
                        case .clientError(let errorResponse):
                            if errorResponse.statusCode == 401 {
                                self.shouldLogOut = true
                            } else {
                                // swiftlint:disable:next fallthrough
                                fallthrough
                            }
                        default: self.error = error
                        }
                    } else {
                        self.error = error
                    }
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.userInfo = result.0
                self.bind(userSettings: result.1)
                self.usableDomains = result.2
            }
            .store(in: &cancellables)
    }

    func forceRefresh() {
        isInitialized = false
        getRequiredInformation()
    }

    private func update(option: UserSettingsUpdateOption) {
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
        self.randomAliasSuffix = userSettings.randomAliasSuffix
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

                self.error = error
                self.biometricAuthEnabled.toggle()
            }
        }
    }

    func uploadNewProfilePhoto(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let resizedImage = image.resized(toWidth: 500),
               let base64String = resizedImage.pngData()?.base64EncodedString() {
                DispatchQueue.main.async {
                    self?.updateProfilePicture(base64String: base64String)
                }
            }
        }
    }

    func removeProfilePhoto() {
        updateProfilePicture(base64String: nil)
    }

    private func updateProfilePicture(base64String: String?) {
        isLoading = true
        session.client.updateProfilePicture(apiKey: session.apiKey, base64ProfilePicture: base64String)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] userInfo in
                guard let self = self else { return }
                self.userInfo = userInfo
            }
            .store(in: &cancellables)
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func updateDisplayName(_ displayName: String) {
        guard !isLoading else { return }
        isLoading = true
        session.client.updateProfileName(apiKey: session.apiKey, name: displayName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] userInfo in
                guard let self = self else { return }
                self.userInfo = userInfo
            }
            .store(in: &cancellables)
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

    var example: String {
        switch self {
        case .uuid: return "hdy792o-ydy8-269d-ojan@example.com"
        case .word: return "meaningless_random@example.com"
        }
    }
}

extension RandomAliasSuffix: CustomStringConvertible {
    public var description: String {
        switch self {
        case .word: return "Random word"
        case .randomString: return "Random 5 characters"
        }
    }

    var example: String {
        switch self {
        case .word: return ".meaningless@example.com"
        case .randomString: return ".u9jnqn@example.com"
        }
    }
}
