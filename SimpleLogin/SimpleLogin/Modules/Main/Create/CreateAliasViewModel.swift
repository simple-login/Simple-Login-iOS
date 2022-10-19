//
//  CreateAliasViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 19/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class CreateAliasViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var options: AliasOptions?
    @Published private(set) var mailboxes: [Mailbox] = []
    @Published private(set) var createdAlias: Alias?

    @Published var error: Error?
    @Published var prefix = ""
    @Published var selectedSuffix: Suffix?
    @Published var mailboxIds = [Int]()
    @Published var notes = ""

    private let session: Session
    private let mode: CreateAliasView.Mode?

    var canCreate: Bool {
        prefix.isValidPrefix && !mailboxIds.isEmpty && selectedSuffix != nil
    }

    init(session: Session, mode: CreateAliasView.Mode?) {
        self.session = session
        self.mode = mode
        switch mode {
        case .url(let url):
            prefix = url.notWwwHostname() ?? ""
            notes = url.host ?? ""
        case .text(let text):
            notes = text
        case .none:
            break
        }
    }

    func fetchOptionsAndMailboxes() {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let getAliasOptionsEndpoint = GetAliasOptionsEndpoint(apiKey: session.apiKey.value)
                let options = try await session.execute(getAliasOptionsEndpoint)
                self.options = options
                self.selectedSuffix = options.suffixes.first

                let getMailboxesEndpoint = GetMailboxesEndpoint(apiKey: session.apiKey.value)
                let mailboxes = try await session.execute(getMailboxesEndpoint).mailboxes
                self.mailboxes = mailboxes.sorted { $0.id < $1.id }
                if let defaultMailbox = mailboxes.first(where: { $0.default }) ?? mailboxes.first {
                    self.mailboxIds.append(defaultMailbox.id)
                }
            } catch {
                self.error = error
            }
        }
    }

    func createAlias() {
        guard let selectedSuffix else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let createAliasEndpoint = CreateAliasEndpoint(apiKey: session.apiKey.value,
                                                              request: .init(prefix: prefix,
                                                                             suffix: selectedSuffix,
                                                                             mailboxIds: mailboxIds,
                                                                             note: notes,
                                                                             name: nil),
                                                              hostname: nil)
                createdAlias = try await session.execute(createAliasEndpoint)
            } catch {
                self.error = error
            }
        }
    }

    func random(mode: RandomMode) {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let randomAliasEndpoint = RandomAliasEndpoint(apiKey: session.apiKey.value,
                                                              note: notes,
                                                              mode: mode,
                                                              hostname: nil)
                createdAlias = try await session.execute(randomAliasEndpoint)
            } catch {
                self.error = error
            }
        }
    }
}
