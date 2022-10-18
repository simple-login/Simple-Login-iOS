//
//  SearchAliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import Combine
import CoreData
import Reachability
import SimpleLoginPackage
import SwiftUI

/*
final class SearchAliasesViewModel: BaseReachabilitySessionViewModel, ObservableObject {
    private let searchTermSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var lastSearchTerm: String?

    @Published private(set) var aliases = [Alias]()
    @Published private(set) var isLoading = false
    @Published private(set) var isUpdating = false
    @Published private(set) var updatedAlias: Alias?
    @Published private(set) var deletedAlias: Alias?
    @Published var error: Error?
    private var currentPage = 0
    private var canLoadMorePages = true

    private let dataController: DataController

    init(session: SessionV2,
         reachabilityObserver: ReachabilityObserver,
         managedObjectContext: NSManagedObjectContext) {
        self.dataController = .init(context: managedObjectContext)
        super.init(session: session, reachabilityObserver: reachabilityObserver)
        searchTermSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [unowned self] term in
                guard term.count >= 2 else {
                    aliases.removeAll()
                    lastSearchTerm = nil
                    return
                }
                self.initialSearch(term: term)
            }
            .store(in: &cancellables)
    }

    override func whenReachable() {
        objectWillChange.send()
    }

    override func whenUnreachable() {
        objectWillChange.send()
    }

    func search(term: String) {
        searchTermSubject.send(term)
    }

    func getMoreAliasesIfNeed(currentAlias alias: Alias) {
        let thresholdIndex = aliases.index(aliases.endIndex, offsetBy: -1)
        guard aliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex else { return }

        guard let lastSearchTerm = lastSearchTerm, canLoadMorePages else { return }

        if !reachabilityObserver.reachable {
            do {
                let fetchedAliases = try dataController.fetchAliases(page: currentPage,
                                                                     searchTerm: lastSearchTerm)
                self.aliases.append(contentsOf: fetchedAliases)
                currentPage += 1
                canLoadMorePages = fetchedAliases.count == kDefaultPageSize
            } catch {
                self.error = error
            }
            return
        }

        guard !isLoading else { return }

        isLoading = true
        session.client.searchAliases(apiKey: session.apiKey, page: currentPage, searchTerm: lastSearchTerm)
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
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    private func initialSearch(term: String) {
        currentPage = 0
        lastSearchTerm = term

        if !reachabilityObserver.reachable {
            do {
                aliases = try dataController.fetchAliases(page: currentPage, searchTerm: term)
                currentPage = 1
                canLoadMorePages = aliases.count == kDefaultPageSize
            } catch {
                self.error = error
            }
            return
        }

        isLoading = true
        session.client.searchAliases(apiKey: session.apiKey, page: 0, searchTerm: term)
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
                self.aliases = aliasArray.aliases
                self.currentPage = 1
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    func update(alias: Alias) {
        guard let index = aliases.firstIndex(where: { $0.id == alias.id }) else { return }
        aliases[index] = alias
    }

    func remove(alias: Alias) {
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
                    self.updatedAlias = updatedAlias
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
                self.deletedAlias = alias
                self.remove(alias: alias)
                do {
                    try self.dataController.delete(alias)
                } catch {
                    self.error = error
                }
            }
            .store(in: &cancellables)
    }
}
*/
