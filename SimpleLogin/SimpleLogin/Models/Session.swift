//
//  Session.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class Session: ObservableObject {
    let apiKey: ApiKey
    let client: SLClient

    init(apiKey: ApiKey, client: SLClient) {
        self.apiKey = apiKey
        self.client = client
    }
}
