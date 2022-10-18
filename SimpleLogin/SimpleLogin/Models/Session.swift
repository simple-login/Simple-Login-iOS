//
//  Session.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class SessionV2: ObservableObject {
    private let apiService: APIServiceProtocol
    let apiKey: ApiKey

    init(apiKey: ApiKey, apiService: APIServiceProtocol) {
        self.apiKey = apiKey
        self.apiService = apiService
    }

    func execute<E: EndpointV2>(_ endpoint: E) async throws ->  E.Response {
        try await apiService.execute(endpoint)
    }
}

final class Session: ObservableObject {
    let apiKey: ApiKey
    let client: SLClient

    init(apiKey: ApiKey, client: SLClient) {
        self.apiKey = apiKey
        self.client = client
    }
}

extension Session {
    // swiftlint:disable force_unwrapping
    static var preview: Session {
        .init(apiKey: .init(value: ""),
              client: .init(session: .shared, baseUrlString: "")!)
    }
}
