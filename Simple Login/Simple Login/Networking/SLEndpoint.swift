//
//  SLEndpoint.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension URL {
    func append(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        // Safely force unwrap because constructing a new url
        // based on another url's elements (scheme, host) always succeed
        // swiftlint:disable:next force_unwrapping
        return components.url!
    }
}

extension URLRequest {
    mutating func addApiKeyToHeaders(_ apiKey: ApiKey) {
        addValue(apiKey.value, forHTTPHeaderField: "Authentication")
    }

    mutating func addJsonRequestBody(_ dict: [String: Any]) {
        httpBody = try? JSONSerialization.data(withJSONObject: dict)
        addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

enum HTTPMethod {
    static let delete = "DELETE"
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
}

enum SLEndpoint {
    case aliases(baseUrl: URL, apiKey: ApiKey, page: Int, searchTerm: String?)
    case aliasActivities(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int)
    case contacts(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int)
    case createContact(baseUrl: URL, apiKey: ApiKey, aliasId: Int, email: String)
    case createMailbox(baseUrl: URL, apiKey: ApiKey, email: String)
    case deleteAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case deleteContact(baseUrl: URL, apiKey: ApiKey, contactId: Int)
    case deleteMailbox(baseUrl: URL, apiKey: ApiKey, mailboxId: Int)
    case getAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case login(baseUrl: URL, email: String, password: String, deviceName: String)
    case mailboxes(baseUrl: URL, apiKey: ApiKey)
    case makeDefaultMailbox(baseUrl: URL, apiKey: ApiKey, mailboxId: Int)
    case randomAlias(baseUrl: URL, apiKey: ApiKey, randomMode: RandomMode)
    case toggleAlias(baseUrl: URL, apiKey: ApiKey, aliasId: Int)
    case updateAliasMailboxes(baseUrl: URL, apiKey: ApiKey, aliasId: Int, mailboxIds: [Int])
    case updateAliasNote(baseUrl: URL, apiKey: ApiKey, aliasId: Int, note: String?)
    case updateAliasName(baseUrl: URL, apiKey: ApiKey, aliasId: Int, name: String?)
    case userInfo(baseUrl: URL, apiKey: ApiKey)

    var path: String {
        switch self {
        case .aliases: return "/api/v2/aliases"
        case .aliasActivities(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/activities"
        case .contacts(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/contacts"
        case .createContact(_, _, let aliasId, _): return "/api/aliases/\(aliasId)/contacts"
        case .createMailbox: return "/api/mailboxes"
        case .deleteAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)"
        case .deleteContact(_, _, let contactId): return "/api/contacts/\(contactId)"
        case .deleteMailbox(_, _, let mailboxId): return "/api/mailboxes/\(mailboxId)"
        case .getAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)"
        case .login: return "/api/auth/login"
        case .mailboxes: return "/api/v2/mailboxes"
        case .makeDefaultMailbox(_, _, let mailboxId): return "/api/mailboxes/\(mailboxId)"
        case .randomAlias: return "/api/alias/random/new"
        case .toggleAlias(_, _, let aliasId): return "/api/aliases/\(aliasId)/toggle"
        case .updateAliasMailboxes(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .updateAliasName(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .updateAliasNote(_, _, let aliasId, _): return "/api/aliases/\(aliasId)"
        case .userInfo: return "/api/user_info"
        }
    }

    var urlRequest: URLRequest {
        switch self {
        case let .aliases(baseUrl, apiKey, page, searchTerm):
            return aliasesRequest(baseUrl: baseUrl, apiKey: apiKey, page: page, searchTerm: searchTerm)

        case let .aliasActivities(baseUrl, apiKey, aliasId, page):
            return aliasActivitiesRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case let .contacts(baseUrl, apiKey, aliasId, page):
            return contactsRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case let .createContact(baseUrl, apiKey, aliasId, email):
            return createContactRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, email: email)

        case let .createMailbox(baseUrl, apiKey, email):
            return createMailboxRequest(baseUrl: baseUrl, apiKey: apiKey, email: email)

        case let .deleteAlias(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .deleteContact(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .deleteMailbox(baseUrl, apiKey, _):
            return deleteRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .getAlias(baseUrl, apiKey, aliasId):
            return getAliasRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)

        case let .login(baseUrl, email, password, deviceName):
            return loginRequest(baseUrl: baseUrl, email: email, password: password, deviceName: deviceName)

        case let .mailboxes(baseUrl, apiKey):
            return mailboxesRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .makeDefaultMailbox(baseUrl, apiKey, mailboxId):
            return makeDefaultMailboxRequest(baseUrl: baseUrl, apiKey: apiKey, mailboxId: mailboxId)

        case let .randomAlias(baseUrl, apiKey, randomMode):
            return randomAlias(baseUrl: baseUrl, apiKey: apiKey, randomMode: randomMode)

        case let .toggleAlias(baseUrl, apiKey, aliasId):
            return toggleAliasRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId)

        case let .updateAliasMailboxes(baseUrl, apiKey, aliasId, mailboxIds):
            return updateAliasMailboxesRequest(baseUrl: baseUrl,
                                               apiKey: apiKey,
                                               aliasId: aliasId,
                                               mailboxIds: mailboxIds)

        case let .updateAliasName(baseUrl, apiKey, aliasId, name):
            return updateAliasNameRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, name: name)

        case let .updateAliasNote(baseUrl, apiKey, aliasId, note):
            return updateAliasNoteRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, note: note)

        case let .userInfo(baseUrl, apiKey):
            return userInfoRequest(baseUrl: baseUrl, apiKey: apiKey)
        }
    }
}

extension SLEndpoint {
    private func aliasesRequest(baseUrl: URL, apiKey: ApiKey, page: Int, searchTerm: String?) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)

        if let searchTerm = searchTerm {
            request.httpMethod = HTTPMethod.post
            request.addJsonRequestBody(["query": searchTerm])
        } else {
            request.httpMethod = HTTPMethod.get
        }

        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func aliasActivitiesRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func contactsRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func createContactRequest(baseUrl: URL,
                                      apiKey: ApiKey,
                                      aliasId: Int,
                                      email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["contact": email])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func createMailboxRequest(baseUrl: URL,
                                      apiKey: ApiKey,
                                      email: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func deleteRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func getAliasRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func loginRequest(baseUrl: URL, email: String, password: String, deviceName: String) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email,
                                    "password": password,
                                    "device": deviceName])

        return request
    }

    private func mailboxesRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func makeDefaultMailboxRequest(baseUrl: URL, apiKey: ApiKey, mailboxId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["default": true])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func randomAlias(baseUrl: URL, apiKey: ApiKey, randomMode: RandomMode) -> URLRequest {
        let queryItem = URLQueryItem(name: "mode", value: randomMode.rawValue)
        let url = baseUrl.append(path: path, queryItems: [queryItem])

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func toggleAliasRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateAliasMailboxesRequest(baseUrl: URL,
                                             apiKey: ApiKey,
                                             aliasId: Int,
                                             mailboxIds: [Int]) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addApiKeyToHeaders(apiKey)
        request.addJsonRequestBody(["mailbox_ids": mailboxIds])

        return request
    }

    private func updateAliasNameRequest(baseUrl: URL,
                                        apiKey: ApiKey,
                                        aliasId: Int,
                                        name: String?) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["name": name as Any])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func updateAliasNoteRequest(baseUrl: URL,
                                        apiKey: ApiKey,
                                        aliasId: Int,
                                        note: String?) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put
        request.addJsonRequestBody(["note": note as Any])
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func userInfoRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest {
        let url = baseUrl.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)
        return request
    }
}
