//
//  MailboxesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import SimpleLoginPackage
import SwiftUI

final class MailboxesViewModel: ObservableObject {
    @Published private(set) var mailboxes = [Mailbox]()
    @Published private(set) var isLoading = false
    @Published var error: Error?

    private let session: SessionV2

    init(session: SessionV2) {
        self.session = session
    }

    func fetchMailboxes(refreshing: Bool) {
        if !refreshing, !mailboxes.isEmpty { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = !refreshing
            do {
                let getMailboxesEndpoint = GetMailboxesEndpoint(apiKey: session.apiKey.value)
                mailboxes = try await session.execute(getMailboxesEndpoint).mailboxes
            } catch {
                self.error = error
            }
        }
    }

    func makeDefault(mailbox: Mailbox) {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let updateMailboxEndpoint = UpdateMailboxEndpoint(apiKey: session.apiKey.value,
                                                                  mailboxID: mailbox.id,
                                                                  option: .default)
                _ = try await session.execute(updateMailboxEndpoint)
                fetchMailboxes(refreshing: true)
            } catch {
                self.error = error
            }
        }
    }

    func delete(mailbox: Mailbox) {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let deleteMailboxEndpoint = DeleteMailboxEndpoint(apiKey: session.apiKey.value,
                                                                  mailboxID: mailbox.id)
                _ = try await session.execute(deleteMailboxEndpoint)
                mailboxes.removeAll { $0.id == mailbox.id }
            } catch {
                self.error = error
            }
        }
    }

    func addMailbox(email: String) {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let createMailboxEndpoint = CreateMailboxEndpoint(apiKey: session.apiKey.value,
                                                                  email: email)
                let mailbox = try await session.execute(createMailboxEndpoint)
                mailboxes.append(mailbox)
            } catch {
                self.error = error
            }
        }
    }

    func refresh() {
        fetchMailboxes(refreshing: true)
    }
}
