//
//  SignUpViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/02/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var registeredEmail: String?
    @Published private(set) var isShowingKeyboard = false
    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
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

    @MainActor
    func register() async {
        defer { isLoading = false }
        isLoading = true
        do {
            let registerEndpoint = RegisterEndpoint(email: email, password: password)
            _ = try await apiService.execute(registerEndpoint)
            self.registeredEmail = email
        } catch {
            self.error = error
        }
    }

    func handledRegisteredEmail() {
        registeredEmail = nil
    }
}
