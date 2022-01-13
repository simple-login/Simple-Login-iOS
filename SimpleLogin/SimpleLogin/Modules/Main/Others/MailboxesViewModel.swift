//
//  MailboxesViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import Combine
import SwiftUI
import SimpleLoginPackage

final class MailboxesViewModel: ObservableObject {
    @Published private(set) var mailboxes = [Mailbox]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    private var cancellables = Set<AnyCancellable>()

    func handledError() {
        error = nil
    }

    func getMailboxes(session: Session) {
        guard !isLoading else { return }
        isLoading = true
        session.client.getMailboxes(apiKey: session.apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error): self.error = error.description
                }
            } receiveValue: { [weak self] mailboxArray in
                guard let self = self else { return }
                self.mailboxes = mailboxArray.mailboxes
            }
            .store(in: &cancellables)
    }
}
