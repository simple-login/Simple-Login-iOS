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
    @Published private(set) var userInfo: UserInfo?
    @Published private(set) var userSettings: UserSettings?
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var error: SLClientError?
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        let localAuthenticationContext = LAContext()
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            biometryType = localAuthenticationContext.biometryType
        }
    }

    func getUserInfoAndSettings(session: Session) {
        guard userInfo == nil && userSettings == nil else { return }
        guard !isLoading else { return }
        isLoading = true
        let getUserInfo = session.client.getUserInfo(apiKey: session.apiKey)
        let getUserSettings = session.client.getUserSettings(apiKey: session.apiKey)
        Publishers.Zip(getUserInfo, getUserSettings)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.userInfo = result.0
                self.userSettings = result.1
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
