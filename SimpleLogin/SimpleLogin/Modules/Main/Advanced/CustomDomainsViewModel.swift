//
//  CustomDomainsViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 13/01/2022.
//

import SimpleLoginPackage
import SwiftUI

final class CustomDomainsViewModel: ObservableObject {
    @Published private(set) var domains: [CustomDomain] = []
    @Published private(set) var noDomain = false
    @Published private(set) var isLoading = false
    @Published var error: Error?

    let session: SessionV2

    init(session: SessionV2) {
        self.session = session
    }

    func fetchCustomDomains(refreshing: Bool) {
        if !refreshing, !domains.isEmpty { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = !refreshing
            do {
                let getDomainsEndpoint = GetCustomDomainsEndpoint(apiKey: session.apiKey.value)
                let domains = try await session.execute(getDomainsEndpoint).customDomains
                self.domains = domains
                self.noDomain = domains.isEmpty
            } catch {
                self.error = error
            }
        }
    }

    func refresh() {
        fetchCustomDomains(refreshing: true)
    }
}
