//
//  CustomDomainsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class CustomDomainsViewModel: ObservableObject {
    deinit {
        print("\(Self.self) is deallocated")
    }

    @Published private(set) var domains: [CustomDomain] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private var cancellables = Set<AnyCancellable>()

    func handledError() {
        error = nil
    }

    func refreshCustomDomains(session: Session, isForced: Bool) {
        if !isForced, !domains.isEmpty { return }
        isLoading = true
        session.client.getCustomDomains(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] customDomainArray in
                self?.domains = customDomainArray.customDomains
            }
            .store(in: &cancellables)
    }
}
