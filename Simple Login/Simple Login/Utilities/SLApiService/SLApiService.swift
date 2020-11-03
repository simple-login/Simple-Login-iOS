//
//  SLApiService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

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
