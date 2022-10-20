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
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var isUpdated = false
    @Published var isLoadingMailboxes = false
    @Published var isUpdating = false
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()
    private let session: Session
    private let onUpdateDomains: ([CustomDomain]) -> Void

    init(domain: CustomDomain,
         session: Session,
         onUpdateDomains: @escaping ([CustomDomain]) -> Void) {
        self.session = session
        self.onUpdateDomains = onUpdateDomains
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

    @MainActor
    func refresh() async {
        do {
            let getDomainsEndpoint = GetCustomDomainsEndpoint(apiKey: session.apiKey.value)
            let domains = try await session.execute(getDomainsEndpoint).customDomains
            onUpdateDomains(domains)
            if let domain = domains.first(where: { $0.id == self.domain.id }) {
                self.domain = domain
            }
        } catch {
            self.error = error
        }
    }

    func update(option: CustomDomainUpdateOption) {
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let updateDomain = UpdateCustomDomainEndpoint(apiKey: session.apiKey.value,
                                                              customDomainID: domain.id,
                                                              option: option)
                let domain = try await session.execute(updateDomain).customDomain
                isUpdated = true
                bind(domain: domain)
            } catch {
                self.error = error
            }
        }
    }

    @MainActor
    func getMailboxes() async {
        defer { isLoadingMailboxes = false }
        isLoadingMailboxes = true
        do {
            let getMailboxesEndpoint = GetMailboxesEndpoint(apiKey: session.apiKey.value)
            mailboxes = try await session.execute(getMailboxesEndpoint).mailboxes
                .filter { $0.verified }
                .sortedById()
        } catch {
            self.error = error
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
