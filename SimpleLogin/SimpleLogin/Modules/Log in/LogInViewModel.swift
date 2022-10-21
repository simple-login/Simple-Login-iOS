//
//  LogInViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/08/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class LogInViewModel: ObservableObject {
    deinit { print("\(Self.self) is deallocated") }

    @AppStorage("Email") var email = ""
    @Published var password = ""

    @Published private(set) var isLoading = false
    @Published private(set) var userLogin: UserLogin?
    @Published private(set) var shouldActivate = false
    @Published private(set) var isShowingKeyboard = false
    @Published private(set) var resetEmail: String?
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()

    private(set) var apiService = APIService.default

    init(apiUrl: String) {
        updateApiUrl(apiUrl)
        observeKeyboardEvents()
    }

    private func observeKeyboardEvents() {
        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillShowNotification, object: nil)
            .sink { [weak self] _ in
                self?.isShowingKeyboard = true
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillHideNotification, object: nil)
            .sink { [weak self] _ in
                self?.isShowingKeyboard = false
            }
            .store(in: &cancellables)
    }

    func updateApiUrl(_ apiUrl: String) {
        if let url = URL(string: apiUrl) {
            apiService = APIService(baseURL: url,
                                    session: .init(configuration: .simpleLogin),
                                    printDebugInformation: featureFlags.printNetworkDebugInformation)
        }
    }

    func handledUserLogin() {
        userLogin = nil
    }

    func handledShouldActivate() {
        shouldActivate = false
    }

    @MainActor
    func logIn() async {
        defer { isLoading = false }
        isLoading = true
        do {
            let logInEndpoint = LogInEndpoint(email: email,
                                              password: password,
                                              device: UIDevice.current.name)
            self.userLogin = try await apiService.execute(logInEndpoint)
        } catch {
            if let apiServiceError = error as? APIServiceError,
               case .clientError(let errorResponse) = apiServiceError,
               errorResponse.statusCode == 422 {
                self.shouldActivate = true
            } else {
                self.error = error
            }
        }
    }

    @MainActor
    func resetPassword(email: String?) async {
        guard let email, !email.isEmpty else { return }
        defer { isLoading = false }
        isLoading = true
        do {
            let forgotPasswordEndpoint = ForgotPasswordEndpoint(email: email)
            let response = try await apiService.execute(forgotPasswordEndpoint)
            if response.value {
                self.resetEmail = email
            } else {
                self.error = SLError.unknown
            }
        } catch {
            self.error = error
        }
    }

    func handledResetEmail() {
        resetEmail = nil
    }
}

extension URLSessionConfiguration {
    static var simpleLogin: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return config
    }
}

private extension APIService {
    static let `default`: APIService = {
        .init(baseURL: URL(string: "https://app.simplelogin.io/")!, // swiftlint:disable:this force_unwrapping
              session: .init(configuration: .simpleLogin),
              printDebugInformation: featureFlags.printNetworkDebugInformation)
    }()
}
