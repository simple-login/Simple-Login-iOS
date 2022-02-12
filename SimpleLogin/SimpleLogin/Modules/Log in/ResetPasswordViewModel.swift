//
//  ResetPasswordViewModel.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class ResetPasswordViewModel: BaseClientViewModel, ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var resetEmail: String?
    private var cancellables = Set<AnyCancellable>()

    func resetPassword(email: String) {
        isLoading = true
        client.forgotPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] ok in
                guard let self = self else { return }
                if ok.value {
                    self.resetEmail = email
                } else {
                    self.error = SLError.unknown
                }
            }
            .store(in: &cancellables)
    }

    func handledError() {
        error = nil
    }

    func handledResetEmail() {
        resetEmail = nil
    }
}
