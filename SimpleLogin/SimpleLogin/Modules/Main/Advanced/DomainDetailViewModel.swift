//
//  DomainDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class DomainDetailViewModel: ObservableObject {
    @Published private(set) var domain: CustomDomain = .empty
    @Published var catchAll = false
    @Published var randomPrefixGeneration = false
    @Published private(set) var isUpdating = false
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var isLoadingMailboxes = false
    @Published private(set) var isUpdated = false
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()
    private let session: SessionV2

    init(domain: CustomDomain, session: SessionV2) {
        self.session = session
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
        guard !isUpdating else { return }
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let updateDomain = UpdateCustomDomainEndpoint(apiKey: session.apiKey.value,
                                                              customDomainID: domain.id,
                                                              option: option)
                let domain = try await session.execute(updateDomain).customDomain
                bind(domain: domain)
            } catch {
                self.error = error
            }
        }
    }

    func getMailboxes() {
        guard !isLoadingMailboxes else { return }
        Task { @MainActor in
            defer { isLoadingMailboxes = false }
            isLoadingMailboxes = true
            do {
                let getMailboxesEndpoint = GetMailboxesEndpoint(apiKey: session.apiKey.value)
                let mailboxes = try await session.execute(getMailboxesEndpoint).mailboxes
                self.mailboxes = mailboxes.sorted { $0.id < $1.id }
            } catch {
                self.error = error
            }
        }
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
