//
//  SLClient.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

/**
 A client that communicates with SimpleLogin server.
 */
final class SLClient {
    static let shared: SLClient = {
        if let slClient = try? SLClient() {
            return slClient
        }
        fatalError("Error making an instance of SLClient")
    }()

    let engine: NetworkEngine
    private(set) var baseUrl: URL

    init(engine: NetworkEngine = URLSession.shared, baseUrlString: String = Settings.shared.apiUrl) throws {
        self.engine = engine

        if let baseUrl = URL(string: baseUrlString) {
            self.baseUrl = baseUrl
        } else {
            throw SLError.badUrlString(urlString: baseUrlString)
        }
    }

    func updateBaseUrlString(_ string: String) {
        if let baseUrl = URL(string: string) {
            self.baseUrl = baseUrl
        }
    }
}

// MARK: - Generic core funtions
extension SLClient {
    func makeCall<T: Decodable>(to endpoint: SLEndpoint,
                                expectedObjectType: T.Type,
                                completion: @escaping (Result<T, SLError>) -> Void) {
        engine.performRequest(for: endpoint.urlRequest) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                self?.handle(data: data, response: response, completion: completion)
            } else {
                completion(.failure(.unknownResponseStatusCode))
            }
        }
    }

    private func handle<T: Decodable>(data: Data,
                                      response: HTTPURLResponse,
                                      completion: @escaping (Result<T, SLError>) -> Void) {
        switch response.statusCode {
        case 200, 201:
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error as? SLError ?? .unknownError(error: error)))
            }

        case 400, 401, 404:
            do {
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                completion(.failure(.badRequest(description: errorMessage.value)))
            } catch {
                completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
            }

        case 500: completion(.failure(.internalServerError))
        case 502: completion(.failure(.badGateway))

        default: completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
        }
    }
}

// MARK: - Shared functions between host app and share extension
extension SLClient {
    func fetchUserOptions(apiKey: ApiKey,
                          hostname: String? = nil,
                          completion: @escaping (Result<UserOptions, SLError>) -> Void) {
        let userOptionsEndpoint = SLEndpoint.userOptions(baseUrl: baseUrl, apiKey: apiKey, hostname: hostname)
        makeCall(to: userOptionsEndpoint, expectedObjectType: UserOptions.self, completion: completion)
    }

    func fetchMailboxes(apiKey: ApiKey, completion: @escaping (Result<MailboxArray, SLError>) -> Void) {
        let mailboxesEndpoint = SLEndpoint.mailboxes(baseUrl: baseUrl, apiKey: apiKey)
        makeCall(to: mailboxesEndpoint, expectedObjectType: MailboxArray.self, completion: completion)
    }
}
