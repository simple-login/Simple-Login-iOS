//
//  AliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasesViewModel: BaseViewModel, ObservableObject {
    @Published private(set) var aliases: [Alias] = []
    private var cancellables = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    private var page = 0

    func fetchMoreAliases() {
        client.getAliases(apiKey: apiKey, page: page)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): break
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases.append(contentsOf: aliasArray.aliases)
                print("Fetched \(self.aliases.count)")
                self.page += 1
            }
            .store(in: &cancellables)
    }

    func refresh() {

    }
}
