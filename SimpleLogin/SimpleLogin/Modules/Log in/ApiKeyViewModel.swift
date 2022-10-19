//
//  ApiKeyViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class ApiKeyViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var apiKey: ApiKey?
    @Published var error: Error?

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func checkApiKey(apiKey: ApiKey) {
        guard !apiKey.value.isEmpty else {
            error = SLError.missingApiKey
            return
        }

        guard !isLoading else { return }

        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let getUserInfoEndpoint = GetUserInfoEndpoint(apiKey: apiKey.value)
                _ = try await apiService.execute(getUserInfoEndpoint)
                self.apiKey = apiKey
            } catch {
                self.error = error
            }
        }
    }
}
