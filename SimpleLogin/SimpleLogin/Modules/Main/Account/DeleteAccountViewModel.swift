//
//  DeleteAccountViewModel.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 27/07/2022.
//

import Combine
import Foundation
import SimpleLoginPackage

final class DeleteAccountViewModel: BaseSessionViewModel, ObservableObject {
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @Published var accountDeleted = false
    private var cancellables = Set<AnyCancellable>()

    func deleteAccount(password: String) {
        isLoading = true
        error = nil
        session.client.enterSudoMode(apiKey: session.apiKey, password: password)
            .append(session.client.deleteUser(apiKey: session.apiKey))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.accountDeleted = true
            }
            .store(in: &cancellables)
    }
}
