//
//  AliasDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class AliasDetailViewModel: ObservableObject {
    @Published private(set) var alias: Alias
    @Published private(set) var activities: [AliasActivity] = []
    @Published private(set) var isLoadingActivities = false
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var isLoadingMailboxes = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isRefreshed = false
    @Published private(set) var isDeleted = false
    @Published var error: Error?

    // Updating mailboxes, display name & notes
    @Published private(set) var isUpdating = false
    @Published private(set) var isUpdated = false
    @Published var updatingError: Error?

    let session: Session
    private var currentPage = 0
    private var canLoadMorePages = true

    init(alias: Alias, session: Session) {
        self.session = session
        self.alias = alias
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
        defer { isLoadingActivities = false }
        isLoadingActivities = true
        Task { @MainActor in
            do {
                let getActivitiesEndpoint = GetActivitiesEndpoint(apiKey: session.apiKey.value,
                                                                  aliasID: alias.id,
                                                                  page: currentPage)
                let result = try await session.execute(getActivitiesEndpoint)
                let newActivities = result.activities
                self.activities.append(contentsOf: newActivities)
                self.currentPage += 1
                self.canLoadMorePages = newActivities.count == kDefaultPageSize
            } catch {
                self.error = error
            }
        }
    }

    func getMailboxes() {
        guard !isLoadingMailboxes else { return }
        Task { @MainActor in
            defer { isLoadingMailboxes = false }
            isLoadingMailboxes = true
            do {
                let getMailboxesEndpoint = GetMailboxesEndpoint(apiKey: session.apiKey.value)
                let result = try await session.execute(getMailboxesEndpoint)
                mailboxes = result.mailboxes.sorted { $0.id < $1.id }
            } catch {
                self.error = error
            }
        }
    }

    func refresh() {
        print("Refreshing \(alias.email)")
        Task { @MainActor in
            defer { isRefreshing = false }
            isRefreshing = true
            do {
                let getAliasEndpoint = GetAliasEndpoint(apiKey: session.apiKey.value,
                                                        aliasID: alias.id)
                let alias = try await session.execute(getAliasEndpoint)
                let getActivitiesEndpoint = GetActivitiesEndpoint(apiKey: session.apiKey.value,
                                                                  aliasID: alias.id,
                                                                  page: 0)
                let activities = try await session.execute(getActivitiesEndpoint).activities
                self.alias = alias
                self.activities = activities
                self.currentPage = 1
                self.canLoadMorePages = activities.count == kDefaultPageSize
                self.isRefreshed = true
            } catch {
                self.error = error
            }
        }
    }

    func update(option: AliasUpdateOption) {
        guard !isUpdating else { return }
        print("Updating \(alias.email)")
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            isUpdated = false
            do {
                let updateAliasEndpoint = UpdateAliasEndpoint(apiKey: session.apiKey.value,
                                                              aliasID: alias.id,
                                                              option: option)
                _ = try await session.execute(updateAliasEndpoint)
                isUpdated = true
                refresh()
            } catch {
                self.updatingError = error
            }
        }
    }

    func toggle() {
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let toggleAliasEndpoint = ToggleAliasEndpoint(apiKey: session.apiKey.value,
                                                              aliasID: alias.id)
                _ = try await session.execute(toggleAliasEndpoint)
                refresh()
            } catch {
                self.error = error
            }
        }
    }

    func delete() {
        Task { @MainActor in
            defer { isUpdating = false }
            isUpdating = true
            do {
                let deleteAliasEndpoint = DeleteAliasEndpoint(apiKey: session.apiKey.value, aliasID: alias.id)
                _ = try await session.execute(deleteAliasEndpoint)
                isDeleted = true
            } catch {
                self.error = error
            }
        }
    }
}
