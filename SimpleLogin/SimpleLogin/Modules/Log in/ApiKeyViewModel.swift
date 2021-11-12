//
//  ApiKeyViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

final class ApiKeyViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var apiKey: ApiKey?
    private var cancellables = Set<AnyCancellable>()
    var client: SLClient?

    func checkApiKey(apiKey: ApiKey) {
        guard let client = client else {
            error = "Invalid API URL"
            return
        }

        guard !apiKey.value.isEmpty else {
            error = "API key is empty"
            return
        }

        guard !isLoading else { return }
        isLoading = true
        client.getUserInfo(apiKey: apiKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                defer { self.isLoading = false }
                switch completion {
                case .failure(let error): self.error = error.description
                case .finished: break
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.apiKey = apiKey
            }
            .store(in: &cancellables)
    }

    func handledError() {
        error = nil
    }
}
