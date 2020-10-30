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
}

// MARK: - Login
extension SLClient {
    func login(email: String,
               password: String,
               deviceName: String,
               completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        guard let urlRequest = SLURLRequest.loginRequest(from: baseUrl,
                                                         email: email,
                                                         password: password,
                                                         deviceName: deviceName) else {
            completion(.failure(.failedToGenerateUrlRequest(endpoint: .login)))
            return
        }
        engine.performRequest(for: urlRequest) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                self?.finalizeLogin(data: data, response: response, completion: completion)
            } else {
                completion(.failure(.unknownResponseStatusCode))
            }
        }
    }

    private func finalizeLogin(data: Data,
                               response: HTTPURLResponse,
                               completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        switch response.statusCode {
        case 200:
            do {
                let userLogin = try JSONDecoder().decode(UserLogin.self, from: data)
                completion(.success(userLogin))
            } catch {
                completion(.failure(error as? SLError ?? .unknownError(error: error)))
            }

        case 400: completion(.failure(.emailOrPasswordIncorrect))
        case 500: completion(.failure(.internalServerError))
        case 502: completion(.failure(.badGateway))
        default: completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
        }
    }
}

// MARK: - Fetch UserInfo
extension SLClient {
    func fetchUserInfo(apiKey: ApiKey, completion: @escaping (Result<UserInfo, SLError>) -> Void) {
        guard let urlRequest = SLURLRequest.fetchUserInfoRequest(from: baseUrl, apiKey: apiKey) else {
            completion(.failure(.failedToGenerateUrlRequest(endpoint: .userInfo)))
            return
        }
        engine.performRequest(for: urlRequest) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                self?.finalizeFetchingUserInfo(data: data, response: response, completion: completion)
            } else {
                completion(.failure(.unknownResponseStatusCode))
            }
        }
    }

    private func finalizeFetchingUserInfo(data: Data,
                                          response: HTTPURLResponse,
                                          completion: @escaping (Result<UserInfo, SLError>) -> Void) {
        switch response.statusCode {
        case 200:
            do {
                let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error as? SLError ?? .unknownError(error: error)))
            }

        case 401: completion(.failure(.invalidApiKey))
        case 500: completion(.failure(.internalServerError))
        case 502: completion(.failure(.badGateway))
        default: completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
        }
    }
}
