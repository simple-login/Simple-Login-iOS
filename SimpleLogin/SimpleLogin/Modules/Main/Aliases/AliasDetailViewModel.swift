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
    @Published var isLoadingMailboxes = false
    @Published var error: Error?

    // Updating mailboxes, display name & notes
    @Published var isUpdating = false
    @Published var isUpdated = false
    @Published var updatingError: Error?

    let session: Session
    private var currentPage = 0
    private var canLoadMorePages = true

    private let onUpdateAlias: (Alias) -> Void
    private let onDeleteAlias: (Alias) -> Void

    init(alias: Alias,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping (Alias) -> Void) {
        self.session = session
        self.alias = alias
        self.onUpdateAlias = onUpdateAlias
        self.onDeleteAlias = onDeleteAlias
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
                let newActivities = try await getActivities(page: currentPage)
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

    private func getActivities(page: Int) async throws -> [AliasActivity] {
        let getActivitiesEndpoint = GetActivitiesEndpoint(apiKey: session.apiKey.value,
                                                          aliasID: alias.id,
                                                          page: page)
        return try await session.execute(getActivitiesEndpoint).activities
    }

    @MainActor
    func refresh() async {
        do {
            let getAliasEndpoint = GetAliasEndpoint(apiKey: session.apiKey.value,
                                                    aliasID: alias.id)
            self.alias = try await session.execute(getAliasEndpoint)
            self.activities = try await getActivities(page: 0)
            self.currentPage = 1
            self.canLoadMorePages = activities.count == kDefaultPageSize
            self.onUpdateAlias(alias)
        } catch {
            self.error = error
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
                await refresh()
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
                await refresh()
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
                onDeleteAlias(alias)
            } catch {
                self.error = error
            }
        }
    }
}
