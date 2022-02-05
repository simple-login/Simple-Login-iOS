//
//  AliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasesViewModel: BaseSessionViewModel, ObservableObject {
    @AppStorage(kHapticFeedbackEnabled) private var hapticEffectEnabled = true
    @Published var selectedStatus: AliasStatus = .all {
        didSet {
            if hapticEffectEnabled {
                Vibration.selection.vibrate()
            }
            updateFilteredAliases()
        }
    }
    @Published private var aliases: [Alias] = [] {
        didSet {
            updateFilteredAliases()
        }
    }
    @Published private(set) var filteredAliases: [Alias] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isUpdating = false
    @Published private(set) var error: Error?
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    func handledError() {
        self.error = nil
    }

    func getMoreAliasesIfNeed(currentAlias alias: Alias?) {
        guard let alias = alias else {
            getMoreAliases()
            return
        }

        let thresholdIndex = filteredAliases.index(filteredAliases.endIndex, offsetBy: -1)
        if filteredAliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex {
            getMoreAliases()
        }
    }

    private func getMoreAliases() {
        guard !isLoading && canLoadMorePages else { return }
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey, page: currentPage)
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
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases.append(contentsOf: aliasArray.aliases)
                self.currentPage += 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }

    private func updateFilteredAliases() {
        filteredAliases = aliases.filter { alias in
            switch selectedStatus {
            case .all: return true
            case .active: return alias.enabled
            case .inactive: return !alias.enabled
            }
        }
    }

    override func refresh() {
        isRefreshing = true
        session.client.getAliases(apiKey: session.apiKey, page: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isRefreshing = false
                self.refreshControl.endRefreshing()
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
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

    func toggle(alias: Alias) {
        guard !isUpdating else { return }
        isUpdating = true
        session.client.toggleAliasStatus(apiKey: session.apiKey, id: alias.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isUpdating = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] enabledResponse in
                guard let self = self else { return }
                guard let index = self.aliases.firstIndex(where: { $0.id == alias.id }) else { return }
                self.aliases[index] = Alias(id: alias.id,
                                            email: alias.email,
                                            name: alias.name,
                                            enabled: enabledResponse.value,
                                            creationTimestamp: alias.creationTimestamp,
                                            blockCount: alias.blockCount,
                                            forwardCount: alias.forwardCount,
                                            replyCount: alias.replyCount,
                                            note: alias.note,
                                            pgpSupported: alias.pgpSupported,
                                            pgpDisabled: alias.pgpDisabled,
                                            mailboxes: alias.mailboxes,
                                            latestActivity: alias.latestActivity,
                                            pinned: alias.pinned)
            }
            .store(in: &cancellables)
    }

    func random(mode: RandomMode) {
        guard !isUpdating else { return }
        isUpdating = true
        session.client.randomAlias(apiKey: session.apiKey, options: AliasRandomOptions(mode: mode))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isUpdating = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.refresh()
            }
            .store(in: &cancellables)
    }
}
