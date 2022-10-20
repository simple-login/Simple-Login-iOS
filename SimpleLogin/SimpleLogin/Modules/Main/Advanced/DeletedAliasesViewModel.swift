//
//  DeletedAliasesViewModel.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 20/10/2022.
//

import SimpleLoginPackage
import SwiftUI

final class DeletedAliasesViewModel: ObservableObject {
    deinit { print("\(Self.self) is deallocated") }

    @Published private(set) var deletedAliases = [DeletedAlias]()
    @Published var isLoading = false
    @Published var error: Error?

    private let session: Session
    let domain: CustomDomain

    var noAliases: Bool { !isLoading && deletedAliases.isEmpty }

    init(session: Session, domain: CustomDomain) {
        self.domain = domain
        self.session = session
    }

    @MainActor
    func refresh(force: Bool) async {
        if !force, !deletedAliases.isEmpty { return }
        defer { isLoading = false }
        if !force { isLoading = true }
        do {
            let getDeletedAliases = GetDeletedAliasesEndpoint(apiKey: session.apiKey.value,
                                                              customDomainID: domain.id)
            deletedAliases = try await session.execute(getDeletedAliases).aliases
        } catch {
            self.error = error
        }
    }

    func relativeDeletedDateString(alias: DeletedAlias) -> String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter.string(for: Date(timeIntervalSince1970: alias.deletionTimestamp))
    }
}
