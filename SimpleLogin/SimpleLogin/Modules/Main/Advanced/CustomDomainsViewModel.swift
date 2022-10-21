//
//  CustomDomainsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import SimpleLoginPackage
import SwiftUI

final class CustomDomainsViewModel: ObservableObject {
    deinit { print("\(Self.self) is deallocated") }

    @Published private(set) var domains: [CustomDomain] = []
    @Published var isLoading = false
    @Published var error: Error?

    var noDomains: Bool { !isLoading && domains.isEmpty }

    let session: Session

    init(session: Session) {
        self.session = session
    }

    @MainActor
    func refresh(force: Bool) async {
        if !force, !domains.isEmpty { return }
        defer { isLoading = false }
        if !force { isLoading = true }
        do {
            let getDomainsEndpoint = GetCustomDomainsEndpoint(apiKey: session.apiKey.value)
            domains = try await session.execute(getDomainsEndpoint).customDomains.sortedById()
        } catch {
            self.error = error
        }
    }

    func update(_ domains: [CustomDomain]) {
        self.domains = domains.sortedById()
    }
}

extension Array where Element == CustomDomain {
    func sortedById() -> Self {
        sorted { $0.id > $1.id }
    }
}
