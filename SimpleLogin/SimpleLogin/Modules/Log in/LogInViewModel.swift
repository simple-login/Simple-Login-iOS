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
    @Published private(set) var error: Error?
    @Published private(set) var userLogin: UserLogin?
    @Published private(set) var shouldActivate = false
    private var cancellables = Set<AnyCancellable>()

    private(set) var client: SLClient = .default

    init(apiUrl: String) {
        updateApiUrl(apiUrl)
    }

    func updateApiUrl(_ apiUrl: String) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        client = .init(session: .init(configuration: config), baseUrlString: apiUrl) ?? .default
    }

    func handledError() {
        error = nil
    }

    func handledUserLogin() {
        userLogin = nil
    }

    func handledShouldActivate() {
        shouldActivate = false
    }

    func logIn(email: String, password: String, device: String) {
        guard !isLoading else { return }
        isLoading = true
        client.login(email: email, password: password, device: device)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let slClientError = error as? SLClientError {
                        switch slClientError {
                        case .clientError(let errorResponse):
                            if errorResponse.statusCode == 400 {
                                self.shouldActivate = true
                            } else {
                                // swiftlint:disable:next fallthrough
                                fallthrough
                            }
                        default:
                            self.error = error
                        }
                    } else {
                        self.error = error
                    }
                }
            } receiveValue: { [weak self] userLogin in
                guard let self = self else { return }
                self.userLogin = userLogin
            }
            .store(in: &cancellables)
    }
}
