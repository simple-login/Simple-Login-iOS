//
//  SLApiService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
// MARK: Login
extension SLApiService {
    func verifyMFA(mfaKey: String,
                   mfaToken: String,
                   completion: @escaping (Result<ApiKey, SLError>) -> Void) {
        let parameters = ["mfa_token": mfaToken, "mfa_key": mfaKey, "device": UIDevice.current.name]

        AF.request("\(baseUrl)/api/auth/mfa",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let apiKey = try JSONDecoder().decode(ApiKey.self, from: data)
                        completion(.success(apiKey))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 400: completion(.failure(.wrongTotpToken))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

    func forgotPassword(email: String, completion: @escaping () -> Void) {
        AF.request("\(baseUrl)/api/auth/forgot_password",
                   method: .post,
                   parameters: ["email": email],
                   encoding: JSONEncoding.default).response { _ in
            completion()
        }
    }
}

// MARK: - Sign Up
extension SLApiService {
    func signUp(email: String, password: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email": email, "password": password]

        AF.request("\(baseUrl)/api/auth/register",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))

                case 400:
                    do {
                        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                        completion(.failure(.badRequest(description: errorMessage.value)))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

    func verifyEmail(email: String, code: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email": email, "code": code]

        AF.request("\(baseUrl)/api/auth/activate",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
                case 400: completion(.failure(.wrongVerificationCode))
                case 410: completion(.failure(.reactivationNeeded))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

    func reactivate(email: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email": email]

        AF.request("\(baseUrl)/api/auth/reactivate",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
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

// MARK: - Alias
extension SLApiService {
    func fetchAliases(apiKey: ApiKey,
                      page: Int,
                      searchTerm: String? = nil,
                      completion: @escaping (Result<[Alias], SLError>) -> Void) {
        let method: HTTPMethod
        let parameters: [String: Any]?
        if let searchTerm = searchTerm {
            parameters = ["query": searchTerm]
            method = .post
        } else {
            parameters = nil
            method = .get
        }

        AF.request("\(baseUrl)/api/v2/aliases?page_id=\(page)",
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let aliases = try [Alias](data: data)
                        completion(.success(aliases))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 400:
                    completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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

    func fetchAliasActivities(apiKey: ApiKey,
                              aliasId: Alias.Identifier,
                              page: Int,
                              completion: @escaping (Result<[AliasActivity], SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(aliasId)/activities?page_id=\(page)",
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let activities = try [AliasActivity](data: data)
                        completion(.success(activities))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 400:
                    completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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

    func randomAlias(apiKey: ApiKey,
                     randomMode: RandomMode,
                     completion: @escaping (Result<Alias, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/alias/random/new?mode=\(randomMode.rawValue)",
                   method: .post,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 201:
                    do {
                        let alias = try Alias(data: data)
                        completion(.success(alias))
                    } catch let slError as SLError {
                        completion(.failure(slError))
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

    func toggleAlias(apiKey: ApiKey,
                     id: Alias.Identifier,
                     completion: @escaping (Result<Enabled, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(id)/toggle",
                   method: .post,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let enabled = try Enabled(data: data)
                        completion(.success(enabled))
                    } catch let slError as SLError {
                        completion(.failure(slError))
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

    func deleteAlias(apiKey: ApiKey,
                     id: Alias.Identifier,
                     completion: @escaping (Result<Any?, SLError>) -> Void) {
        delete(apiKey: apiKey, requestUrlString: "\(baseUrl)/api/aliases/\(id)", completion: completion)
    }

    func updateAliasNote(apiKey: ApiKey,
                         id: Alias.Identifier,
                         note: String?,
                         completion: @escaping (Result<Any?, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(id)",
                   method: .put,
                   parameters: ["note": note as Any],
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).response { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
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

    func getAlias(apiKey: ApiKey,
                  id: Alias.Identifier,
                  completion: @escaping (Result<Alias, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(id)",
                   method: .get,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let alias = try Alias(data: data)
                        completion(.success(alias))
                    } catch let slError as SLError {
                        completion(.failure(slError))
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

    func updateAliasName(apiKey: ApiKey,
                         id: Alias.Identifier,
                         name: String?,
                         completion: @escaping (Result<Any?, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(id)",
                   method: .put,
                   parameters: ["name": name as Any],
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).response { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
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

    func updateAliasMailboxes(apiKey: ApiKey,
                              id: Alias.Identifier,
                              mailboxIds: [Int],
                              completion: @escaping (Result<Any?, SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(id)",
                   method: .put,
                   parameters: ["mailbox_ids": mailboxIds],
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).response { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
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
}

// MARK: - Contact
extension SLApiService {
    func fetchContacts(apiKey: ApiKey,
                       aliasId: Alias.Identifier,
                       page: Int,
                       completion: @escaping (Result<[Contact], SLError>) -> Void) {
        AF.request("\(baseUrl)/api/aliases/\(aliasId)/contacts?page_id=\(page)",
                   method: .get,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let contacts = try [Contact](data: data)
                        completion(.success(contacts))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 400:
                    completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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

    func createContact(apiKey: ApiKey,
                       aliasId: Alias.Identifier,
                       email: String,
                       completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["contact": email]

        AF.request("\(baseUrl)/api/aliases/\(aliasId)/contacts",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).response { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 201: completion(.success(nil))
                case 401: completion(.failure(.invalidApiKey))
                case 409: completion(.failure(.duplicatedContact))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

    func deleteContact(apiKey: ApiKey,
                       id: Contact.Identifier,
                       completion: @escaping (Result<Any?, SLError>) -> Void) {
        delete(apiKey: apiKey, requestUrlString: "\(baseUrl)/api/contacts/\(id)", completion: completion)
    }
}

// MARK: - IAP
extension SLApiService {
    func processPayment(apiKey: ApiKey,
                        receiptData: String,
                        completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["receipt_data": receiptData]

        AF.request("\(baseUrl)/api/apple/process_payment",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: apiKey.toHeaders()).response { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))
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
}

// MARK: - Mailbox
extension SLApiService {
    func createMailbox(apikey: ApiKey, email: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email": email]

        AF.request("\(baseUrl)/api/mailboxes",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: apikey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 201: completion(.success(nil))

                case 400:
                    do {
                        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                        completion(.failure(.badRequest(description: errorMessage.value)))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }

            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }

    func deleteMailbox(apiKey: ApiKey, id: Int, completion: @escaping (Result<Any?, SLError>) -> Void) {
        delete(apiKey: apiKey, requestUrlString: "\(baseUrl)/api/mailboxes/\(id)", completion: completion)
    }

    func makeDefaultMailbox(apikey: ApiKey, id: Int, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["default": true]

        AF.request("\(baseUrl)/api/mailboxes/\(id)",
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: apikey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200: completion(.success(nil))

                case 400:
                    do {
                        let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                        completion(.failure(.badRequest(description: errorMessage.value)))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }

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

// MARK: Delete
extension SLApiService {
    private func delete(apiKey: ApiKey,
                        requestUrlString: String,
                        completion: @escaping (Result<Any?, SLError>) -> Void) {
        AF.request(requestUrlString,
                   method: .delete,
                   encoding: URLEncoding.default,
                   headers: apiKey.toHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }

                switch statusCode {
                case 200:
                    do {
                        let deleted = try Deleted(data: data)
                        deleted.value ? completion(.success(nil)) :
                            completion(.failure(.failedToDelete(anyObject: Alias.self)))
                    } catch let slError as SLError {
                        completion(.failure(slError))
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
}
