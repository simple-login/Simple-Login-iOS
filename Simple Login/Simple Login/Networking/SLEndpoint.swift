//
//  SLEndpoint.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension URL {
    func componentsFor(path: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        return components
    }
}

extension URLRequest {
    mutating func addApiKeyToHeaders(_ apiKey: ApiKey) {
        addValue(apiKey.value, forHTTPHeaderField: "Authentication")
    }

    mutating func addJsonRequestBody(_ dict: [String: String]) {
        httpBody = try? JSONEncoder().encode(dict)
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
    case dummyLogin
    case login(baseUrl: URL, email: String, password: String, deviceName: String)
    case mailboxes(baseUrl: URL, apiKey: ApiKey)
    case userInfo(baseUrl: URL, apiKey: ApiKey)

    var path: String {
        switch self {
        case .aliases: return "/api/v2/aliases"
        case let .aliasActivities(_, _, aliasId, _):
            return "/api/aliases/\(aliasId)/activities"
        case let .contacts(_, _, aliasId, _):
            return "/api/aliases/\(aliasId)/contacts"
        case .dummyLogin: return "/dummy/login"
        case .login: return "/api/auth/login"
        case .mailboxes: return "/api/mailboxes"
        case .userInfo: return "/api/user_info"
        }
    }

    var urlRequest: URLRequest? {
        switch self {
        case let .aliases(baseUrl, apiKey, page, searchTerm):
            return aliasesRequest(baseUrl: baseUrl, apiKey: apiKey, page: page, searchTerm: searchTerm)

        case let .aliasActivities(baseUrl, apiKey, aliasId, page):
            return aliasActivitiesRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case let .contacts(baseUrl, apiKey, aliasId, page):
            return contactsRequest(baseUrl: baseUrl, apiKey: apiKey, aliasId: aliasId, page: page)

        case .dummyLogin: return nil

        case let .login(baseUrl, email, password, deviceName):
            return loginRequest(baseUrl: baseUrl, email: email, password: password, deviceName: deviceName)

        case let .mailboxes(baseUrl, apiKey):
            return mailboxesRequest(baseUrl: baseUrl, apiKey: apiKey)

        case let .userInfo(baseUrl, apiKey):
            return userInfoRequest(baseUrl: baseUrl, apiKey: apiKey)
        }
    }
}

extension SLEndpoint {
    private func aliasesRequest(baseUrl: URL, apiKey: ApiKey, page: Int, searchTerm: String?) -> URLRequest? {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        guard let url = baseUrl.componentsFor(path: path, queryItems: [queryItem]).url else { return nil }

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

    private func aliasActivitiesRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest? {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        guard let url = baseUrl.componentsFor(path: path, queryItems: [queryItem]).url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func contactsRequest(baseUrl: URL, apiKey: ApiKey, aliasId: Int, page: Int) -> URLRequest? {
        let queryItem = URLQueryItem(name: "page_id", value: "\(page)")
        guard let url = baseUrl.componentsFor(path: path, queryItems: [queryItem]).url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func loginRequest(baseUrl: URL, email: String, password: String, deviceName: String) -> URLRequest? {
        guard let url = baseUrl.componentsFor(path: path).url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.addJsonRequestBody(["email": email,
                                    "password": password,
                                    "device": deviceName])

        return request
    }

    private func mailboxesRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest? {
        guard let url = baseUrl.componentsFor(path: path).url else { return  nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)

        return request
    }

    private func userInfoRequest(baseUrl: URL, apiKey: ApiKey) -> URLRequest? {
        guard let url = baseUrl.componentsFor(path: path).url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.addApiKeyToHeaders(apiKey)
        return request
    }
}
