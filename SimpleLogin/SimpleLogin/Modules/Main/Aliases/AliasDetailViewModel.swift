//
//  AliasDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasDetailViewModel: ObservableObject {
    @Published private(set) var alias: Alias
    @Published private(set) var activities: [AliasActivity] = []
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    init(alias: Alias) {
        self.alias = alias
    }

    func getMoreActivitiesIfNeed(session: Session, currentActivity activity: AliasActivity?) {
        guard let activity = activity else {
            getMoreActivities(session: session)
            return
        }

        let thresholdIndex = activities.index(activities.endIndex, offsetBy: -5)
        if activities.firstIndex(where: { $0.timestamp == activity.timestamp }) == thresholdIndex {
            getMoreActivities(session: session)
        }
    }

    private func getMoreActivities(session: Session) {
        guard !isLoading && canLoadMorePages else { return }
        isLoading = true
        session.client.getAliasActivities(apiKey: session.apiKey, id: alias.id, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: Handle error
                    break
                }
            } receiveValue: { [weak self] activityArray in
                guard let self = self else { return }
                self.activities.append(contentsOf: activityArray.activities)
                self.currentPage += 1
                self.canLoadMorePages = activityArray.activities.count == 20
            }
            .store(in: &cancellables)
    }
}
