//
//  SearchAliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import Combine
import Foundation

final class SearchAliasesViewModel: BaseSessionViewModel, ObservableObject {
    private let searchTermSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    override init(session: Session) {
        super.init(session: session)
        searchTermSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { $0.count >= 2 }
            .sink { [unowned self] term in
                self._search(term: term)
            }
            .store(in: &cancellables)
    }

    func search(term: String) {
        searchTermSubject.send(term)
    }

    private func _search(term: String) {}
}
