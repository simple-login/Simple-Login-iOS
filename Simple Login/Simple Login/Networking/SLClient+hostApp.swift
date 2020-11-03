//
//  SLClient+hostApp.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

// MARK: - Alias
extension SLClient {
    func deleteAlias(apiKey: ApiKey,
                     aliasId: Int,
                     completion: @escaping (Result<Deleted, SLError>) -> Void) {
        let deleteAliasEndpoint = SLEndpoint.deleteAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)
        makeCall(to: deleteAliasEndpoint, expectedObjectType: Deleted.self, completion: completion)
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

    func getAlias(apiKey: ApiKey,
                  aliasId: Int,
                  completion: @escaping (Result<Alias, SLError>) -> Void) {
        let getAliasEndpoint = SLEndpoint.getAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)
        makeCall(to: getAliasEndpoint, expectedObjectType: Alias.self, completion: completion)
    }

    func randomAlias(apiKey: ApiKey,
                     randomMode: RandomMode,
                     completion: @escaping (Result<Alias, SLError>) -> Void) {
        let randomAliasEndpoint = SLEndpoint.randomAlias(baseUrl: baseUrl, apiKey: apiKey, randomMode: randomMode)
        makeCall(to: randomAliasEndpoint, expectedObjectType: Alias.self, completion: completion)
    }

    func toggleAlias(apiKey: ApiKey,
                     aliasId: Int,
                     completion: @escaping (Result<Enabled, SLError>) -> Void) {
        let toggleAliasEndpoint = SLEndpoint.toggleAlias(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)
        makeCall(to: toggleAliasEndpoint, expectedObjectType: Enabled.self, completion: completion)
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
    func createContact(apiKey: ApiKey,
                       aliasId: Int,
                       email: String,
                       completion: @escaping (Result<Contact, SLError>) -> Void) {
        let createContactEndpoint =
            SLEndpoint.createContact(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, email: email)
        makeCall(to: createContactEndpoint, expectedObjectType: Contact.self, completion: completion)
    }

    func deleteContact(apiKey: ApiKey,
                       contactId: Int,
                       completion: @escaping (Result<Deleted, SLError>) -> Void) {
        let deleteContactEndpoint =
            SLEndpoint.deleteContact(baseUrl: baseUrl, apiKey: apiKey, contactId: contactId)
        makeCall(to: deleteContactEndpoint, expectedObjectType: Deleted.self, completion: completion)
    }

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

// MARK: - Mailbox
extension SLClient {
    func createMailbox(apiKey: ApiKey,
                       email: String,
                       completion: @escaping (Result<Mailbox, SLError>) -> Void) {
        let createMailboxEndpoint = SLEndpoint.createMailbox(baseUrl: baseUrl, apiKey: apiKey, email: email)
        makeCall(to: createMailboxEndpoint, expectedObjectType: Mailbox.self, completion: completion)
    }

    func deleteMailbox(apiKey: ApiKey,
                       mailboxId: Int,
                       completion: @escaping (Result<Deleted, SLError>) -> Void) {
        let deleteMailboxEndpoint =
            SLEndpoint.deleteMailbox(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId)
        makeCall(to: deleteMailboxEndpoint, expectedObjectType: Deleted.self, completion: completion)
    }

    func makeDefaultMailbox(apiKey: ApiKey,
                            mailboxId: Int,
                            completion: @escaping (Result<Updated, SLError>) -> Void) {
        let makeDefaultMailboxEndpoint =
            SLEndpoint.makeDefaultMailbox(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId)
        makeCall(to: makeDefaultMailboxEndpoint, expectedObjectType: Updated.self, completion: completion)
    }
}

// MARK: - Payment
extension SLClient {
    func processPayment(apiKey: ApiKey,
                        receiptData: String,
                        completion: @escaping (Result<Ok, SLError>) -> Void) {
        let processPaymentEndpoint =
            SLEndpoint.processPayment(baseUrl: baseUrl, apiKey: apiKey, receiptData: receiptData)
        makeCall(to: processPaymentEndpoint, expectedObjectType: Ok.self, completion: completion)
    }
}
