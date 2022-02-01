//
//  CustomDomainsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class CustomDomainsViewModel: BaseViewModel, ObservableObject {
    deinit {
        print("\(Self.self) is deallocated")
    }

    @Published private(set) var domains: [CustomDomain] = []
    @Published private(set) var noDomain = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private var cancellables = Set<AnyCancellable>()

    func handledError() {
        self.error = nil
    }

    func fetchCustomDomains(refreshing: Bool) {
        if !refreshing, !domains.isEmpty { return }
        isLoading = !refreshing
        session.client.getCustomDomains(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                self.refreshControl.endRefreshing()
                switch completion {
                case .finished:
                    self.noDomain = self.domains.isEmpty
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] customDomainArray in
                self?.domains = customDomainArray.customDomains
            }
            .store(in: &cancellables)
    }

    override func refresh() {
        fetchCustomDomains(refreshing: true)
    }
}
