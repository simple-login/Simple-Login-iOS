//
//  SignUpViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 01/02/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class SignUpViewModel: BaseClientViewModel, ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var registeredEmail: String?
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()

    func register(email: String, password: String) {
        isLoading = true
        client.register(email: email, password: password)
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
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.registeredEmail = email
            }
            .store(in: &cancellables)
    }

    func handledRegisteredEmail() {
        registeredEmail = nil
    }
}
