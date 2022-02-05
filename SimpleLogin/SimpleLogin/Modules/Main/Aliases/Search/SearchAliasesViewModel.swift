//
//  SearchAliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import Combine
import Foundation
import SimpleLoginPackage

final class SearchAliasesViewModel: BaseSessionViewModel, ObservableObject {
    private let searchTermSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var lastSearchTerm: String?

    @Published private(set) var aliases = [Alias]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    private var currentPage = 0
    private var canLoadMorePages = true

    override init(session: Session) {
        super.init(session: session)
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

    func handledError() {
        error = nil
    }

    func search(term: String) {
        searchTermSubject.send(term)
    }

    func getMoreAliasesIfNeed(currentAlias alias: Alias) {
        let thresholdIndex = aliases.index(aliases.endIndex, offsetBy: -1)
        guard aliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex else { return }

        guard let lastSearchTerm = lastSearchTerm, canLoadMorePages, !isLoading else { return }

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
}
