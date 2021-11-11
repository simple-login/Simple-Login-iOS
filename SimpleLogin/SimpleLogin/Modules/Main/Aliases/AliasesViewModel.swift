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
    @Published private(set) var aliases: [Alias] = []
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

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
                case .failure(let error):
                    // TODO: Handle error
                    break
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases.append(contentsOf: aliasArray.aliases)
                self.currentPage += 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }

    func refresh() {

    }

    func update(alias: Alias) {
        guard let index = aliases.firstIndex(where: { $0.id == alias.id }) else { return }
        aliases[index] = alias
    }
}
