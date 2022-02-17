//
//  AliasDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasDetailViewModel: BaseSessionViewModel, ObservableObject {
    @Published private(set) var alias: Alias
    @Published private(set) var activities: [AliasActivity] = []
    @Published private(set) var isLoadingActivities = false
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var isLoadingMailboxes = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isRefreshed = false
    @Published private(set) var isDeleted = false
    @Published private(set) var error: Error?

    // Updating mailboxes, display name & notes
    @Published private(set) var isUpdating = false
    @Published private(set) var isUpdated = false
    @Published private(set) var updatingError: Error?

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    init(alias: Alias, session: Session) {
        self.alias = alias
        super.init(session: session)
    }

    func handledError() {
        error = nil
    }

    func handledUpdatingError() {
        updatingError = nil
    }

    func handledIsUpdatedBoolean() {
        isUpdated = false
    }

    func handledIsRefreshedBoolean() {
        isRefreshed = false
    }

    func getMoreActivitiesIfNeed(currentActivity activity: AliasActivity?) {
        guard let activity = activity else {
            getMoreActivities()
            return
        }

        let thresholdIndex = activities.index(activities.endIndex, offsetBy: -5)
        if activities.firstIndex(where: { $0.timestamp == activity.timestamp }) == thresholdIndex {
            getMoreActivities()
        }
    }

    private func getMoreActivities() {
        guard !isLoadingActivities && canLoadMorePages else { return }
        isLoadingActivities = true
        session.client.getAliasActivities(apiKey: session.apiKey, id: alias.id, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingActivities = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] activityArray in
                guard let self = self else { return }
                self.activities.append(contentsOf: activityArray.activities)
                self.currentPage += 1
                self.canLoadMorePages = activityArray.activities.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    func getMailboxes() {
        guard !isLoadingMailboxes else { return }
        isLoadingMailboxes = true
        session.client.getMailboxes(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingMailboxes = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] mailboxArray in
                guard let self = self else { return }
                self.mailboxes = mailboxArray.mailboxes.sorted { $0.id < $1.id }
            }
            .store(in: &cancellables)
    }

    override func refresh() {
        print("Refreshing \(alias.email)")
        isRefreshing = true
        let refreshAlias = session.client.getAlias(apiKey: session.apiKey, id: alias.id)
        let refreshActivities = session.client.getAliasActivities(apiKey: session.apiKey, id: alias.id, page: 0)
        Publishers.Zip(refreshAlias, refreshActivities)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isRefreshing = false
                self.isRefreshed = true
                self.refreshControl.endRefreshing()
                switch completion {
                case .finished:
                    print("Finish refreshing \(self.alias.email)")
                case .failure(let error):
                    print("Error refreshing \(self.alias.email)")
                    self.error = error
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.alias = result.0
                self.activities = result.1.activities
                self.currentPage = 1
                self.canLoadMorePages = result.1.activities.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    func update(option: AliasUpdateOption) {
        guard !isUpdating else { return }
        print("Updating \(alias.email)")
        isUpdating = true
        isUpdated = false
        session.client.updateAlias(apiKey: session.apiKey, id: alias.id, option: option)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isUpdating = false
                switch completion {
                case .finished:
                    print("Finish updating \(self.alias.email)")
                    self.isUpdated = true
                case .failure(let error):
                    print("Error updating \(self.alias.email): \(error.safeLocalizedDescription)")
                    self.updatingError = error
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.refresh()
            }
            .store(in: &cancellables)
    }

    func toggle() {
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
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.refresh()
            }
            .store(in: &cancellables)
    }

    func delete() {
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
                self.isDeleted = true
            }
            .store(in: &cancellables)
    }
}
