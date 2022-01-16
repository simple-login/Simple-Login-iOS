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
    deinit {
        print("\(Self.self) deallocated: \(domain.domainName)")
    }

    @Published private(set) var domain: CustomDomain = .empty
    @Published var catchAll = false
    @Published var randomPrefixGeneration = false
    @Published private(set) var isLoading = false
    @Published private(set) var isUpdated = false
    @Published private(set) var error: String?
    private var cancellables = Set<AnyCancellable>()
    private var session: Session?

    init(domain: CustomDomain) {
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

    func setSession(_ session: Session) {
        self.session = session
    }

    func handledError() {
        self.error = nil
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
        guard let session = session else { return }
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
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] customDomain in
                self?.bind(domain: customDomain)
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
