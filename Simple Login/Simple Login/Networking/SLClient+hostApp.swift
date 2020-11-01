//
//  SLClient+hostApp.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

extension SLClient {
    func login(email: String,
               password: String,
               deviceName: String,
               completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        let loginEndpoint = SLEndpoint.login(baseUrl: baseUrl,
                                             email: email,
                                             password: password,
                                             deviceName: deviceName)
        makeCall(to: loginEndpoint, expectedObjectType: UserLogin.self, completion: completion)
    }

    func fetchUserInfo(apiKey: ApiKey, completion: @escaping (Result<UserInfo, SLError>) -> Void) {
        let userInfoEndpoint = SLEndpoint.userInfo(baseUrl: baseUrl, apiKey: apiKey)
        makeCall(to: userInfoEndpoint, expectedObjectType: UserInfo.self, completion: completion)
    }

    func fetchAliases(apiKey: ApiKey,
                      page: Int,
                      searchTerm: String? = nil,
                      completion: @escaping (Result<AliasArray, SLError>) -> Void) {
        let aliasesEndpoint = SLEndpoint.aliases(baseUrl: baseUrl,
                                                 apiKey: apiKey,
                                                 page: page,
                                                 searchTerm: searchTerm)
        makeCall(to: aliasesEndpoint, expectedObjectType: AliasArray.self, completion: completion)
    }
}
