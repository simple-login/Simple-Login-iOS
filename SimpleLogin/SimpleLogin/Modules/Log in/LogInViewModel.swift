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
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var userLogin: UserLogin?
    private var cancellables = Set<AnyCancellable>()

    private(set) var client: SLClient?

    init(apiUrl: String) {
        client = .init(session: .shared, baseUrlString: apiUrl)
    }

    func updateApiUrl(_ apiUrl: String) {
        client = .init(session: .shared, baseUrlString: apiUrl)
    }

    func handledError() {
        error = nil
    }

    func handledUserLogin() {
        userLogin = nil
    }

    func logIn(email: String, password: String, device: String) {
        guard let client = client else {
            error = "Invalid API URL"
            return
        }

        guard !isLoading else { return }
        isLoading = true

        client.login(email: email, password: password, device: device)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] userLogin in
                guard let self = self else { return }
                self.userLogin = userLogin
            }
            .store(in: &cancellables)
    }
}
