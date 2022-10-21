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
    @Published private(set) var isFetchingContacts = false
    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var createdContact: Contact?
    @Published var isLoading = false
    @Published var error: Error?

    private let session: Session
    private var currentPage = 0
    private var canLoadMorePages = true

    let alias: Alias

    init(alias: Alias, session: Session) {
        self.alias = alias
        self.session = session
    }

    func getMoreContactsIfNeed(currentContact: Contact?) {
        guard let currentContact = currentContact else {
            getMoreContacts()
            return
        }

        let thresholdIndex = contacts.index(contacts.endIndex, offsetBy: -1)
        if contacts.firstIndex(where: { $0.id == currentContact.id }) == thresholdIndex {
            getMoreContacts()
        }
    }

    private func getMoreContacts() {
        guard !isFetchingContacts && canLoadMorePages else { return }
        Task { @MainActor in
            defer { isFetchingContacts = false }
            isFetchingContacts = true
            do {
                let newContacts = try await getContacts(page: currentPage)
                self.contacts.append(contentsOf: newContacts)
                self.currentPage += 1
                self.canLoadMorePages = newContacts.count == kDefaultPageSize
            } catch {
                self.error = error
            }
        }
    }

    @MainActor
    func refresh() async {
        do {
            let contacts = try await getContacts(page: 0)
            self.contacts = contacts
            self.currentPage = 1
            self.canLoadMorePages = contacts.count == kDefaultPageSize
        } catch {
            self.error = error
        }
    }

    private func getContacts(page: Int) async throws -> [Contact] {
        let getContactsEndpoint = GetContactsEndpoint(apiKey: session.apiKey.value,
                                                      aliasID: alias.id,
                                                      page: page)
        return try await session.execute(getContactsEndpoint).contacts
    }

    func toggleContact(_ contact: Contact) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let toggleContactEndpoint = ToggleContactEndpoint(apiKey: session.apiKey.value,
                                                                  contactID: contact.id)
                let blockForward = try await session.execute(toggleContactEndpoint)
                update(contact: .init(id: contact.id,
                                      email: contact.email,
                                      creationTimestamp: contact.creationTimestamp,
                                      lastEmailSentTimestamp: contact.lastEmailSentTimestamp,
                                      reverseAlias: contact.reverseAlias,
                                      reverseAliasAddress: contact.reverseAliasAddress,
                                      existed: contact.existed,
                                      blockForward: blockForward.value))
            } catch {
                self.error = error
            }
        }
    }

    func deleteContact(_ contact: Contact) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let deleteContactEndpoint = DeleteContactEndpoint(apiKey: session.apiKey.value,
                                                                  contactID: contact.id)
                let result = try await session.execute(deleteContactEndpoint)
                if result.value {
                    await refresh()
                }
            } catch {
                self.error = error
            }
        }
    }

    private func update(contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        contacts[index] = contact
    }

    func createContact(contactEmail: String) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let createContactEndpoint = CreateContactEndpoint(apiKey: session.apiKey.value,
                                                                  aliasID: alias.id,
                                                                  email: contactEmail)
                let createdContact = try await session.execute(createContactEndpoint)
                if createdContact.existed {
                    self.error = SLError.contactExists
                } else {
                    self.createdContact = createdContact
                    self.contacts.insert(createdContact, at: 0)
                }
            } catch {
                self.error = error
            }
        }
    }

    func handledCreatedContact() {
        self.createdContact = nil
    }
}
