//
//  SLApiService+SharedFunctions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

// swiftlint:disable cyclomatic_complexity
final class SLApiService {
    private init() {}

    static let shared = SLApiService()

    private(set) var baseUrl: String = "https://app.simplelogin.io"

    func refreshBaseUrl() {
        baseUrl = Settings.shared.apiUrl
    }
}

// Functions in this file are shared with the Share Extension
extension SLApiService {
    // swiftlint:disable:next function_parameter_count
    func createAlias(apiKey: ApiKey,
                     prefix: String,
                     suffix: Suffix,
                     mailboxIds: [Int],
                     name: String?,
                     note: String?,
                     completion: @escaping (Result<Alias, SLError>) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey.value]
        var parameters: [String: Any] =
            [
                "alias_prefix": prefix,
                "signed_suffix": suffix.value[1],
                "mailbox_ids": mailboxIds
            ]

        if let name = name { parameters["name"] = name }
        if let note = note { parameters["note"] = note }

        AF.request("\(baseUrl)/api/v3/alias/custom/new",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers,
                   interceptor: nil).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 201:
                    do {
                        let alias = try JSONDecoder().decode(Alias.self, from: data)
                        completion(.success(alias))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 400, 405:
                    do {
                        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                        completion(.failure(.badRequest(description: errorMessage.value)))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 401: completion(.failure(.invalidApiKey))
                case 409: completion(.failure(.duplicatedAlias))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }
}
