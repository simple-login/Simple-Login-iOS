//
//  SLClient+hostApp.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

// MARK: - Alias
extension SLClient {
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

    func fetchAliasActivities(apiKey: ApiKey,
                              aliasId: Int,
                              page: Int,
                              completion: @escaping (Result<AliasActivityArray, SLError>) -> Void) {
        let aliasActivitiesEndpoint = SLEndpoint.aliasActivities(baseUrl: baseUrl,
                                                                 apiKey: apiKey,
                                                                 aliasId: aliasId,
                                                                 page: page)
        makeCall(to: aliasActivitiesEndpoint, expectedObjectType: AliasActivityArray.self, completion: completion)
    }

    func updateAliasMailboxes(apiKey: ApiKey,
                              aliasId: Int,
                              mailboxIds: [Int],
                              completion: @escaping (Result<Ok, SLError>) -> Void ) {
        let updateAliasMailboxesEndpoint =
            SLEndpoint.updateAliasMailboxes(baseUrl: baseUrl,
                                            apiKey: apiKey,
                                            aliasId: aliasId,
                                            mailboxIds: mailboxIds)
        makeCall(to: updateAliasMailboxesEndpoint, expectedObjectType: Ok.self, completion: completion)
    }

    func updateAliasName(apiKey: ApiKey,
                         aliasId: Int,
                         name: String?,
                         completion: @escaping (Result<Ok, SLError>) -> Void) {
        let updateAliasNameEndpoint =
            SLEndpoint.updateAliasName(baseUrl: baseUrl,
                                       apiKey: apiKey,
                                       aliasId: aliasId,
                                       name: name)
        makeCall(to: updateAliasNameEndpoint, expectedObjectType: Ok.self, completion: completion)
    }

    func updateAliasNote(apiKey: ApiKey,
                         aliasId: Int,
                         note: String?,
                         completion: @escaping (Result<Ok, SLError>) -> Void) {
        let updateAliasNoteEndpoint =
            SLEndpoint.updateAliasNote(baseUrl: baseUrl,
                                       apiKey: apiKey,
                                       aliasId: aliasId,
                                       note: note)
        makeCall(to: updateAliasNoteEndpoint, expectedObjectType: Ok.self, completion: completion)
    }
}

// MARK: - Contact
extension SLClient {
    func fetchContacts(apiKey: ApiKey,
                       aliasId: Int,
                       page: Int,
                       completion: @escaping (Result<ContactArray, SLError>) -> Void) {
        let contactsEndpoint = SLEndpoint.contacts(baseUrl: baseUrl,
                                                   apiKey: apiKey,
                                                   aliasId: aliasId,
                                                   page: page)
        makeCall(to: contactsEndpoint, expectedObjectType: ContactArray.self, completion: completion)
    }
}

// MARK: - Login
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
}
