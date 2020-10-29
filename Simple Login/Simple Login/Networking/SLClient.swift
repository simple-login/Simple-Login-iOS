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
        engine.performRequest(for: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                self.finalizeLogin(data: data, response: response, completion: completion)
            } else {
                completion(.failure(.unknownResponseStatusCode))
            }
        }
    }

    func finalizeLogin(data: Data,
                       response: HTTPURLResponse,
                       completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        switch response.statusCode {
        case 200:
            do {
                let userLogin = try JSONDecoder().decode(UserLogin.self, from: data)
                completion(.success(userLogin))
            } catch {
                completion(.failure(.unknownError(error: error)))
            }
        default: completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
        }
    }
}
