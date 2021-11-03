//
//  BaseViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage

class BaseViewModel {
    let apiKey: ApiKey
    let client: SLClient

    init(apiKey: ApiKey, client: SLClient) {
        self.apiKey = apiKey
        self.client = client
    }
}
