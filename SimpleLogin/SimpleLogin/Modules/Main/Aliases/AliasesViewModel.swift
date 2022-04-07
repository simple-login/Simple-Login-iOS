//
//  AliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import CoreData
import Reachability
import SimpleLoginPackage
import SwiftUI

final class AliasesViewModel: BaseReachabilitySessionViewModel, ObservableObject {
    @Published var selectedStatus: AliasStatus = .all {
        didSet {
            Vibration.selection.vibrate()
            updateFilteredAliases()
        }
    }

    private var aliases: [Alias] = [] {
        didSet {
            updateFilteredAliases()
        }
    }
    @Published private(set) var filteredAliases: [Alias] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isUpdating = false
    @Published private(set) var error: Error?
    private var handledCreatedAliasIds = Set<Int>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    private let dataController: DataController

    init(session: Session,
         reachabilityObserver: ReachabilityObserver,
         managedObjectContext: NSManagedObjectContext) {
        self.dataController = .init(context: managedObjectContext)
        super.init(session: session, reachabilityObserver: reachabilityObserver)
    }

    override func whenReachable() {
        if aliases.isEmpty {
            getMoreAliasesIfNeed(currentAlias: nil)
        } else {
            refresh()
        }
    }

    override func whenUnreachable() {
        if aliases.isEmpty {
            getMoreAliases()
        }
    }

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
        // Offline
        if !reachabilityObserver.reachable {
            guard canLoadMorePages else { return }
            do {
                let fetchedAliases = try dataController.fetchAliases(page: currentPage)
                aliases.append(contentsOf: fetchedAliases)
                currentPage += 1
                canLoadMorePages = fetchedAliases.count == kDefaultPageSize
            } catch {
                self.error = error
            }
            return
        }

        // Online
        guard !isLoading, canLoadMorePages else { return }
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.isLoading = false
                self.aliases.append(contentsOf: aliasArray.aliases)
                self.currentPage += 1
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
                do {
                    try self.dataController.update(aliasArray.aliases)
                } catch {
                    self.error = error
                }
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
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
                do {
                    try self.dataController.update(aliasArray.aliases)
                } catch {
                    self.error = error
                }
            }
            .store(in: &cancellables)
    }

    func update(alias: Alias) {
        guard let index = aliases.firstIndex(where: { $0.id == alias.id }) else { return }
        aliases[index] = alias
        do {
            try dataController.update(alias)
        } catch {
            self.error = error
        }
    }

    func remove(alias: Alias) {
        aliases.removeAll { $0.id == alias.id }
        do {
            try dataController.delete(alias)
        } catch {
            self.error = error
        }
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
                let updatedAlias = Alias(id: alias.id,
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
                self.aliases[index] = updatedAlias
                do {
                    try self.dataController.update(updatedAlias)
                } catch {
                    self.error = error
                }
            }
            .store(in: &cancellables)
    }

    func update(alias: Alias, option: AliasUpdateOption) {
        guard !isUpdating else { return }
        isUpdating = true
        session.client.updateAlias(apiKey: session.apiKey, id: alias.id, option: option)
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
                guard let index = self.aliases.firstIndex(where: { $0.id == alias.id }) else { return }
                switch option {
                case .pinned(let pinned):
                    let updatedAlias = Alias(id: alias.id,
                                             email: alias.email,
                                             name: alias.name,
                                             enabled: alias.enabled,
                                             creationTimestamp: alias.creationTimestamp,
                                             blockCount: alias.blockCount,
                                             forwardCount: alias.forwardCount,
                                             replyCount: alias.replyCount,
                                             note: alias.note,
                                             pgpSupported: alias.pgpSupported,
                                             pgpDisabled: alias.pgpDisabled,
                                             mailboxes: alias.mailboxes,
                                             latestActivity: alias.latestActivity,
                                             pinned: pinned)
                    self.aliases[index] = updatedAlias
                    do {
                        try self.dataController.update(updatedAlias)
                    } catch {
                        self.error = error
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func delete(alias: Alias) {
        isUpdating = true
        session.client.deleteAlias(apiKey: session.apiKey, id: alias.id)
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
                self.remove(alias: alias)
            }
            .store(in: &cancellables)
    }

    func handleCreatedAlias(_ createdAlias: Alias) {
        guard !handledCreatedAliasIds.contains(createdAlias.id) else { return }
        handledCreatedAliasIds.insert(createdAlias.id)
        refresh()
    }
}
