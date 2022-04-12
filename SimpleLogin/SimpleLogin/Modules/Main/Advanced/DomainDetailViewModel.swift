//
//  DomainDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class DomainDetailViewModel: BaseSessionViewModel, ObservableObject {
    @Published private(set) var domain: CustomDomain = .empty
    @Published var catchAll = false
    @Published var randomPrefixGeneration = false
    @Published private(set) var isLoading = false
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var isLoadingMailboxes = false
    @Published private(set) var isUpdated = false
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()

    init(domain: CustomDomain, session: Session) {
        super.init(session: session)
        bind(domain: domain)

        $catchAll
            .sink { [weak self] selectedCatchAll in
                guard let self = self else { return }
                if selectedCatchAll != self.catchAll {
                    self.update(option: .catchAll(selectedCatchAll))
                }
            }
            .store(in: &cancellables)

        $randomPrefixGeneration
            .sink { [weak self] selectedRandomPrefixGeneration in
                guard let self = self else { return }
                if selectedRandomPrefixGeneration != self.randomPrefixGeneration {
                    self.update(option: .randomPrefixGeneration(selectedRandomPrefixGeneration))
                }
            }
            .store(in: &cancellables)
    }

    func handledIsUpdatedBoolean() {
        isUpdated = false
    }

    private func bind(domain: CustomDomain) {
        self.domain = domain
        self.catchAll = domain.catchAll
        self.randomPrefixGeneration = domain.randomPrefixGeneration
    }

    func update(option: CustomDomainUpdateOption) {
        guard !isLoading else { return }
        isLoading = true
        session.client.updateCustomDomain(apiKey: session.apiKey,
                                          id: domain.id,
                                          option: option)
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
            } receiveValue: { [weak self] customDomain in
                self?.bind(domain: customDomain)
            }
            .store(in: &cancellables)
    }

    func getMailboxes() {
        guard !isLoadingMailboxes else { return }
        isLoadingMailboxes = true
        session.client.getMailboxes(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingMailboxes = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] mailboxArray in
                guard let self = self else { return }
                self.mailboxes = mailboxArray.mailboxes.sorted { $0.id < $1.id }
            }
            .store(in: &cancellables)
    }
}

private extension CustomDomain {
    static var empty: CustomDomain {
        CustomDomain(id: 0,
                     creationTimestamp: 0,
                     domainName: "",
                     name: nil,
                     verified: false,
                     aliasCount: 0,
                     randomPrefixGeneration: false,
                     mailboxes: [],
                     catchAll: false)
    }
}
