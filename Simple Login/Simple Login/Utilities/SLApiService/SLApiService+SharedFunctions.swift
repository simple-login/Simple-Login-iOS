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
    func fetchUserOptions(apiKey: ApiKey,
                          hostname: String? = nil,
                          completion: @escaping (Result<UserOptions, SLError>) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey.value]

        let urlString: String
        if let hostname = hostname {
            urlString = "\(baseUrl)/api/v4/alias/options?hostname=\(hostname)"
        } else {
            urlString = "\(baseUrl)/api/v4/alias/options"
        }

        AF.request(urlString,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: headers,
                   interceptor: nil).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let userOptions = try JSONDecoder().decode(UserOptions.self, from: data)
                        completion(.success(userOptions))
                    } catch let error as SLError {
                        completion(.failure(error))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 401: completion(.failure(.invalidApiKey))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

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
