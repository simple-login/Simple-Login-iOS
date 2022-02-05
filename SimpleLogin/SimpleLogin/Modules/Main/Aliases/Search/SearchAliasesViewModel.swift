//
//  SearchAliasesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import Combine
import Foundation

final class SearchAliasesViewModel: ObservableObject {
    private let searchTermSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let session: Session

    init(session: Session) {
        self.session = session
        searchTermSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { $0.count >= 2 }
            .sink { term in
                print(term)
            }
            .store(in: &cancellables)
    }

    func search(term: String) {
        searchTermSubject.send(term)
    }
}
