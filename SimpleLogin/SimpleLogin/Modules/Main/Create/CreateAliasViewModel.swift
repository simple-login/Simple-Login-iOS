//
//  CreateAliasViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 19/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class CreateAliasViewModel: BaseSessionViewModel, ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var options: AliasOptions?
    @Published private(set) var mailboxes: [Mailbox]?
    @Published private(set) var createdAlias: Alias?
    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()

    func fetchOptionsAndMailboxes() {
        isLoading = true
        let getOptions = session.client.getAliasOptions(apiKey: session.apiKey, hostname: nil)
        let getMailboxes = session.client.getMailboxes(apiKey: session.apiKey)
        Publishers.Zip(getOptions, getMailboxes)
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
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.options = result.0
                self.mailboxes = result.1.mailboxes.sorted { $0.id < $1.id }
            }
            .store(in: &cancellables)
    }

    func createAlias(options: AliasCreationOptions) {
        guard !isLoading else { return }
        isLoading = true
        session.client.createAlias(apiKey: session.apiKey, options: options)
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
            } receiveValue: { [weak self] createdAlias in
                guard let self = self else { return }
                self.createdAlias = createdAlias
            }
            .store(in: &cancellables)
    }

    func random(mode: RandomMode) {
        guard !isLoading else { return }
        isLoading = true
        session.client.randomAlias(apiKey: session.apiKey,
                                   options: AliasRandomOptions(mode: mode))
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
            } receiveValue: { [weak self] randomAlias in
                guard let self = self else { return }
                self.createdAlias = randomAlias
            }
            .store(in: &cancellables)
    }
}
