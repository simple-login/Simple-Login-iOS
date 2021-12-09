//
//  AliasContactsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class AliasContactsViewModel: ObservableObject {
    let alias: Alias

    @Published private(set) var isLoadingContacts = false
    @Published private(set) var isCreatingContact = false
    @Published private(set) var contacts: [Contact]?
    @Published private(set) var error: SLClientError?

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var canLoadMorePages = true

    init(alias: Alias) {
        self.alias = alias
    }

    func handledError() {
        self.error = nil
    }

    func getMoreContactsIfNeed(session: Session, currentContact: Contact?) {
        guard let currentContact = currentContact, let contacts = contacts else {
            getMoreContacts(session: session)
            return
        }

        let thresholdIndex = contacts.index(contacts.endIndex, offsetBy: -1)
        if contacts.firstIndex(where: { $0.id == currentContact.id }) == thresholdIndex {
            getMoreContacts(session: session)
        }
    }

    private func getMoreContacts(session: Session) {
        guard !isLoadingContacts && canLoadMorePages else { return }
        isLoadingContacts = true
        session.client.getAliasContacts(apiKey: session.apiKey, id: alias.id, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingContacts = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error
                }
            } receiveValue: { [weak self] contactArray in
                guard let self = self else { return }
                if self.contacts == nil {
                    self.contacts = [Contact]()
                }
                self.contacts?.append(contentsOf: contactArray.contacts)
                self.currentPage += 1
                self.canLoadMorePages = contactArray.contacts.count == 20
            }
            .store(in: &cancellables)
    }
}
