//
//  AccountViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AuthenticationServices
import Combine
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

final class AccountViewModel: ObservableObject {
    @Published private(set) var userInfo: UserInfo = .empty
    private(set) var usableDomains: [UsableDomain] = []
    private var lastKnownUserSettings: UserSettings?
    @Published var notification = false
    @Published var randomMode: RandomMode = .uuid
    @Published var randomAliasDefaultDomain: UsableDomain?
    @Published var senderFormat: SenderFormat = .a
    @Published var randomAliasSuffix: RandomAliasSuffix = .word
    @Published var askingForSettings = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var message: String?
    @Published var linkToProtonUrlString: String?
    @Published private(set) var isInitialized = false
    @Published private(set) var shouldLogOut = false
    private var cancellables = Set<AnyCancellable>()
    let session: Session

    init(session: Session) {
        self.session = session
        let shouldUpdateUserSettings: () -> Bool = { [unowned self] in
            self.isInitialized && self.error == nil
        }

        $isLoading
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.error = nil
                }
            }
            .store(in: &cancellables)

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
            .sink { [weak self] selectedUsableDomain in
                guard let self = self else { return }
                if let selectedUsableDomain = selectedUsableDomain,
                   shouldUpdateUserSettings(),
                   selectedUsableDomain != self.randomAliasDefaultDomain {
                    self.update(option: .randomAliasDefaultDomain(selectedUsableDomain.domain))
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

    @MainActor
    func refresh(force: Bool) async {
        if !force, isInitialized { return }
        defer { isLoading = false }
        isLoading = true
        do {
            let getUserInfoEndpoint = GetUserInfoEndpoint(apiKey: session.apiKey.value)
            let getUserSettingsEndpoint = GetUserSettingsEndpoint(apiKey: session.apiKey.value)
            let getUsableDomainsEndpoint = GetUsableDomainsEndpoint(apiKey: session.apiKey.value)

            let userInfo = try await session.execute(getUserInfoEndpoint)
            let userSettings = try await session.execute(getUserSettingsEndpoint)
            let usableDomains = try await session.execute(getUsableDomainsEndpoint)

            self.userInfo = userInfo
            bind(userSettings: userSettings)
            self.usableDomains = usableDomains
            // swiftlint:disable:next line_length
            self.randomAliasDefaultDomain = usableDomains.first { $0.domain == userSettings.randomAliasDefaultDomain }
            isInitialized = true
        } catch {
            if let apiServiceError = error as? APIServiceError,
               case .clientError(let errorResponse) = apiServiceError,
               errorResponse.statusCode == 401 {
                self.shouldLogOut = true
                return
            }
            self.error = error
        }
    }

    private func update(option: UserSettingsUpdateOption) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let updateUserSettingsEndpoint = UpdateUserSettingsEndpoint(apiKey: session.apiKey.value,
                                                                            option: option)
                let userSettings = try await session.execute(updateUserSettingsEndpoint)
                bind(userSettings: userSettings)
            } catch {
                self.error = error
                if let lastKnownUserSettings = self.lastKnownUserSettings {
                    self.bind(userSettings: lastKnownUserSettings)
                }
            }
        }
    }

    private func bind(userSettings: UserSettings) {
        self.notification = userSettings.notification
        self.randomMode = userSettings.randomMode
        self.randomAliasDefaultDomain = usableDomains.first { $0.domain == userSettings.randomAliasDefaultDomain }
        self.senderFormat = userSettings.senderFormat
        self.randomAliasSuffix = userSettings.randomAliasSuffix
        self.lastKnownUserSettings = userSettings
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
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let updateProfilePictureEndpoint = UpdateUserInfoEndpoint(apiKey: session.apiKey.value,
                                                                          option: .profilePicture(base64String))
                userInfo = try await session.execute(updateProfilePictureEndpoint)
            } catch {
                self.error = error
            }
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func updateDisplayName(_ displayName: String) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let updateDisplayNameEndpoint = UpdateUserInfoEndpoint(apiKey: session.apiKey.value,
                                                                       option: .name(displayName))
                userInfo = try await session.execute(updateDisplayNameEndpoint)
            } catch {
                self.error = error
            }
        }
    }

    func connectWithProtonAction(apiUrl: String) {
        if userInfo.connectedProtonAddress == nil {
            linkToProton(apiUrl: apiUrl)
        } else {
            unlinkFromProton()
        }
    }

    private func linkToProton(apiUrl: String) {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let getCookieTokenEndpoint = GetCookieTokenEndpoint(apiKey: session.apiKey.value)
                let token = try await session.execute(getCookieTokenEndpoint)
                let scheme = "auth.simplelogin"
                let action = "link"
                let next = "link"
                // swiftlint:disable:next line_length
                let linkToProtonUrlString = "\(apiUrl)/auth/api_to_cookie?token=\(token.value)&next=%2Fauth%2Fproton%2Flogin%3Faction%3D\(action)%26next%3D%2F\(next)%26scheme%3D\(scheme)"
                self.linkToProtonUrlString = linkToProtonUrlString
            } catch {
                self.error = error
            }
        }
    }

    private func unlinkFromProton() {
        Task { @MainActor in
            isLoading = true
            do {
                let unlinkProtonEndpoint = UnlinkProtonAccountEndpoint(apiKey: session.apiKey.value)
                _ = try await session.execute(unlinkProtonEndpoint)
                self.message = "Your Proton account has been unlinked"
                self.isLoading = false
                await refresh(force: true)
            } catch {
                self.isLoading = false
                self.error = error
            }
        }
    }

    func handleLinkingResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if url.absoluteString.contains("link") {
                message = "Your Proton account has been successfully linked"
                Task {
                    await refresh(force: true)
                }
            }

        case .failure(let error):
            if let webAuthenticationSessionError = error as? ASWebAuthenticationSessionError {
                // User clicks on cancel button => do not handle this "error"
                if case ASWebAuthenticationSessionError.canceledLogin = webAuthenticationSessionError {
                    return
                }
            }
            self.error = error
        }
    }
}

extension UserInfo {
    static var empty: UserInfo {
        UserInfo(name: "",
                 email: "",
                 profilePictureUrl: nil,
                 isPremium: false,
                 inTrial: false,
                 maxAliasFreePlan: 0,
                 connectedProtonAddress: nil)
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

extension UsableDomain: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.domain == rhs.domain
    }
}
