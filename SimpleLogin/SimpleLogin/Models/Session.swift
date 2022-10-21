//
//  Session.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class Session: ObservableObject {
    private let apiService: APIServiceProtocol
    let apiKey: ApiKey

    init(apiKey: ApiKey, apiService: APIServiceProtocol) {
        self.apiKey = apiKey
        self.apiService = apiService
    }

    func execute<E: Endpoint>(_ endpoint: E) async throws ->  E.Response {
        try await apiService.execute(endpoint)
    }
}

// swiftlint:disable force_unwrapping
extension Session {
    static var preview: Session {
        .init(apiKey: .init(value: ""), apiService: APIService.preview)
    }
}

extension APIService {
    static var preview: APIService {
        .init(baseURL: URL(string: "https://simplelogin.io")!,
              session: .shared,
              printDebugInformation: false)
    }
}
