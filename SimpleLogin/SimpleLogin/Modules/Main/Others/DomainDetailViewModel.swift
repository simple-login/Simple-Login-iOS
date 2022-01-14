//
//  DomainDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class DomainDetailViewModel: ObservableObject {
    deinit {
        print("\(Self.self) deallocated: \(domain.domainName)")
    }

    @Published private(set) var domain: CustomDomain = .empty
    @Published var catchAll = false
    @Published var randomPrefixGeneration = false
    private var cancellables = Set<AnyCancellable>()

    init(domain: CustomDomain) {
        bind(domain: domain)

        $catchAll
            .sink { [weak self] catchAll in
                guard let self = self else { return }
//                if shouldUpdateUserSettings(), selectedNotification != self.notification {
//                    self.update(option: .notification(selectedNotification))
//                }
                print(catchAll)
            }
            .store(in: &cancellables)

        $randomPrefixGeneration
            .sink { [weak self] randomPrefixGeneration in
                guard let self = self else { return }
                print(randomPrefixGeneration)
            }
            .store(in: &cancellables)
    }

    private func bind(domain: CustomDomain) {
        self.domain = domain
        self.catchAll = domain.catchAll
        self.randomPrefixGeneration = domain.randomPrefixGeneration
    }
}

private extension CustomDomain {
    static var empty: CustomDomain {
        CustomDomain(id: 0,
                     creationTimestamp: 0,
                     domainName: "",
                     name: nil,
                     verified: false,
                     aliasCount: 0,
                     randomPrefixGeneration: false,
                     mailboxes: [],
                     catchAll: false)
    }
}
