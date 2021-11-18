//
//  AliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasesViewModel: ObservableObject {
    @Published var selectedStatus: AliasStatus = .all {
        willSet {
            if selectedStatus != newValue {
                updateFilteredAliases()
            }
        }
    }
    @Published private(set) var aliases: [Alias] = [] {
        didSet {
            updateFilteredAliases()
        }
    }
    @Published private(set) var filteredAliases: [Alias] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var error: SLClientError?
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    func handledError() {
        self.error = nil
    }

    func getMoreAliasesIfNeed(session: Session, currentAlias alias: Alias?) {
        guard let alias = alias else {
            getMoreAliases(session: session)
            return
        }

        let thresholdIndex = aliases.index(aliases.endIndex, offsetBy: -5)
        if aliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex {
            getMoreAliases(session: session)
        }
    }

    private func getMoreAliases(session: Session) {
        guard !isLoading && canLoadMorePages else { return }
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases.append(contentsOf: aliasArray.aliases)
                self.currentPage += 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }

    private func updateFilteredAliases() {
        
    }

    func refresh(session: Session) {
        guard !isRefreshing else { return }
        isRefreshing = true
        session.client.getAliases(apiKey: session.apiKey, page: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isRefreshing = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases = aliasArray.aliases
                self.currentPage = 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }

    func update(alias: Alias) {
        guard let index = aliases.firstIndex(where: { $0.id == alias.id }) else { return }
        aliases[index] = alias
    }

    func delete(alias: Alias) {
        aliases.removeAll { $0.id == alias.id }
    }
}
