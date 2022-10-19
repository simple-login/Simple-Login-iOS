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
            refresh()
        }
    }

    @Published private(set) var aliases: [Alias] = []
    @Published private(set) var updatedAlias: Alias?
    @Published private(set) var isLoading = false
    @Published private(set) var isUpdating = false
    @Published var error: Error?
    private var handledCreatedAliasIds = Set<Int>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    private var filterOption: AliasFilterOption? {
        switch selectedStatus {
        case .all:
            return nil
        case .active:
            return .enabled
        case .inactive:
            return .disabled
        }
    }

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

    func getMoreAliasesIfNeed(currentAlias alias: Alias?) {
        guard let alias = alias else {
            getMoreAliases()
            return
        }

        let thresholdIndex = aliases.index(aliases.endIndex, offsetBy: -1)
        if aliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex {
            getMoreAliases()
        }
    }

    private func getMoreAliases() {
        // Offline
        if !reachabilityObserver.reachable {
            guard canLoadMorePages else { return }
            do {
                let fetchedAliases = try dataController.fetchAliases(page: currentPage,
                                                                     option: filterOption)
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
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let getAliasesEndpoint = GetAliasesEndpoint(apiKey: session.apiKey.value,
                                                            page: currentPage,
                                                            option: .filter(filterOption))
                let result = try await session.execute(getAliasesEndpoint)
                let newAliases = result.aliases
                self.aliases.append(contentsOf: newAliases)
                self.currentPage += 1
                self.canLoadMorePages = newAliases.count == kDefaultPageSize
                try self.dataController.update(newAliases)
            } catch {
                self.error = error
            }
        }
    }

    func refresh() {
        if !reachabilityObserver.reachable {
//            refreshControl.endRefreshing()
        }
        aliases.removeAll()
        currentPage = 0
        canLoadMorePages = true
        getMoreAliases()
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
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let toggleAliasEndpoint = ToggleAliasEndpoint(apiKey: session.apiKey.value,
                                                              aliasID: alias.id)
                let enabledResponse = try await session.execute(toggleAliasEndpoint)
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
                self.updatedAlias = updatedAlias
                switch self.selectedStatus {
                case .all:
                    self.aliases[index] = updatedAlias
                case .active, .inactive:
                    self.aliases.remove(at: index)
                }
                try self.dataController.update(updatedAlias)
            } catch {
                self.error = error
            }
        }
    }

    func update(alias: Alias, option: AliasUpdateOption) {
        guard !isUpdating else { return }
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let updateAliasEndpoint = UpdateAliasEndpoint(apiKey: session.apiKey.value,
                                                              aliasID: alias.id,
                                                              option: option)
                _ = try await session.execute(updateAliasEndpoint)
                guard let index = self.aliases.firstIndex(where: { $0.id == alias.id }) else { return }
                if case .pinned(let pinned) = option {
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
                    try self.dataController.update(updatedAlias)
                }
            } catch {
                self.error = error
            }
        }
    }

    func delete(alias: Alias) {
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let deleteAliasEndpoint = DeleteAliasEndpoint(apiKey: session.apiKey.value,
                                                              aliasID: alias.id)
                _ = try await session.execute(deleteAliasEndpoint)
                self.remove(alias: alias)
            } catch {
                self.error = error
            }
        }
    }

    func handleCreatedAlias(_ createdAlias: Alias) {
        guard !isHandled(createdAlias) else { return }
        handledCreatedAliasIds.insert(createdAlias.id)
        selectedStatus = .all
        refresh()
    }

    func isHandled(_ createdAlias: Alias) -> Bool {
        handledCreatedAliasIds.contains(createdAlias.id)
    }
}
