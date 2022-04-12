//
//  LocalAuthenticator.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 22/02/2022.
//

import LocalAuthentication
import SwiftUI

final class LocalAuthenticator: ObservableObject {
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var isBiometricallyAuthenticating = false
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false {
        didSet {
            biometricallyAuthenticate()
        }
    }
    @Published var message: String?
    @Published var error: Error?

    init() {
        let localAuthenticationContext = LAContext()
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            biometryType = localAuthenticationContext.biometryType
        }
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
