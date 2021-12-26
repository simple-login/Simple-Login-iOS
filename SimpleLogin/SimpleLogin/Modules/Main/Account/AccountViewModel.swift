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

final class AccountViewModel: ObservableObject {
    private(set) var userInfo: UserInfo = .empty
    private(set) var usableDomains: [UsableDomain] = []
    @Published var notification = false
    @Published var randomMode: RandomMode = .uuid
    @Published var randomAliasDefaultDomain = ""
    @Published var senderFormat: SenderFormat = .a
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var error: SLClientError?
    @Published private(set) var isInitialized = false
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        let localAuthenticationContext = LAContext()
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            biometryType = localAuthenticationContext.biometryType
        }

        $notification
            .sink { [weak self] selectedNotification in
                guard let self = self else { return }
                if self.isInitialized, selectedNotification != self.notification {
                    print("Notification changed: \(selectedNotification.description)")
                }
            }
            .store(in: &cancellables)

        $randomMode
            .sink { [weak self] selectedRandomMode in
                guard let self = self else { return }
                if self.isInitialized, selectedRandomMode != self.randomMode {
                    print("Random mode changed: \(selectedRandomMode.rawValue)")
                }
            }
            .store(in: &cancellables)

        $randomAliasDefaultDomain
            .sink { [weak self] selectedRandomAliasDefaultDomain in
                guard let self = self else { return }
                if self.isInitialized, selectedRandomAliasDefaultDomain != self.randomAliasDefaultDomain {
                    print("Default domain changed: \(selectedRandomAliasDefaultDomain)")
                }
            }
            .store(in: &cancellables)

        $senderFormat
            .sink { [weak self] selectedSenderFormat in
                guard let self = self else { return }
                if self.isInitialized, selectedSenderFormat != self.senderFormat {
                    print("Sender format changed: \(selectedSenderFormat.description)")
                }
            }
            .store(in: &cancellables)
    }

    func getRequiredInformation(session: Session) {
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
                let userSettings = result.1
                self.notification = userSettings.notification
                self.randomMode = userSettings.randomMode
                self.randomAliasDefaultDomain = userSettings.randomAliasDefaultDomain
                self.senderFormat = userSettings.senderFormat
                self.usableDomains = result.2
            }
            .store(in: &cancellables)
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
