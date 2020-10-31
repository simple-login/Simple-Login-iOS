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
    let baseUrl: URL

    init(engine: NetworkEngine = URLSession.shared, baseUrlString: String = kDefaultBaseUrlString) throws {
        self.engine = engine

        if let baseUrl = URL(string: baseUrlString) {
            self.baseUrl = baseUrl
        } else {
            throw SLError.badUrlString(urlString: baseUrlString)
        }
    }

    private func makeCall<T: Decodable>(to endpoint: SLEndpoint,
                                        expectedObjectType: T.Type,
                                        completion: @escaping (Result<T, SLError>) -> Void) {
        guard let urlRequest = endpoint.urlRequest else {
            completion(.failure(.failedToGenerateUrlRequest(endpoint: endpoint)))
            return
        }

        engine.performRequest(for: urlRequest) { [weak self] data, response, error in
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
        case 200:
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error as? SLError ?? .unknownError(error: error)))
            }

        case 400:
            do {
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                completion(.failure(.badRequest(description: errorMessage.value)))
            } catch {
                completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
            }

        case 401: completion(.failure(.invalidApiKey))
        case 500: completion(.failure(.internalServerError))
        case 502: completion(.failure(.badGateway))

        default: completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
        }
    }
}

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
