//
//  SLApiService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Login
extension SLApiService {
    static func login(email: String, password: String, completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        let parameters = ["email" : email, "password" : password, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let userLogin = try UserLogin(data: data)
                        completion(.success(userLogin))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch let error {
                        completion(.failure(.unknownError(error: error)))
                    }
                    
                case 400: completion(.failure(.emailOrPasswordIncorrect))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }
                
            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }
    
    static func verifyMFA(mfaKey: String, mfaToken: String, completion: @escaping (Result<ApiKey, SLError>) -> Void) {
        let parameters = ["mfa_token" : mfaToken, "mfa_key" : mfaKey, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/mfa", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let apiKey = try ApiKey(data: data)
                        completion(.success(apiKey))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch let error {
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
    
    static func forgotPassword(email: String, completion: @escaping () -> Void) {
        AF.request("\(BASE_URL)/api/auth/forgot_password", method: .post, parameters: ["email": email], encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            completion()
        }
    }
    
    static func fetchUserInfo(apiKey: ApiKey, completion: @escaping (Result<UserInfo, SLError>) -> Void) {
        AF.request("\(BASE_URL)/api/user_info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let userInfo = try UserInfo(data: data)
                        completion(.success(userInfo))
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
}

// MARK: - Sign Up
extension SLApiService {
    static func signUp(email: String, password: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email" : email, "password" : password]
        
        AF.request("\(BASE_URL)/api/auth/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseData { response in
            
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
                        let errorMessage = try ErrorMessage(data: data)
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
    
    static func verifyEmail(email: String, code: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email" : email, "code" : code]
        
        AF.request("\(BASE_URL)/api/auth/activate", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(_):
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
    
    static func reactivate(email: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["email" : email]
        
        AF.request("\(BASE_URL)/api/auth/reactivate", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(_):
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
    static func fetchAliases(apiKey: ApiKey, page: Int, searchTerm: String? = nil, completion: @escaping (Result<[Alias], SLError>) -> Void) {
        let method: HTTPMethod
        let parameters: [String: Any]?
        if let searchTerm = searchTerm {
            parameters = ["query": searchTerm]
            method = .post
        } else {
            parameters = nil
            method = .get
        }
        
        AF.request("\(BASE_URL)/api/v2/aliases?page_id=\(page)", method: method, parameters: parameters, encoding: JSONEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
                    
                case 400: completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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
    
    static func fetchAliasActivities(apiKey: ApiKey, aliasId: Alias.Identifier, page: Int, completion: @escaping (Result<[AliasActivity], SLError>) -> Void) {
        
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/activities?page_id=\(page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
                    
                case 400: completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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
    
    static func randomAlias(apiKey: ApiKey, randomMode: RandomMode, completion: @escaping (Result<Alias, SLError>) -> Void) {
        
        AF.request("\(BASE_URL)/api/alias/random/new?mode=\(randomMode.rawValue)", method: .post, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
    
    static func toggleAlias(apiKey: ApiKey, id: Alias.Identifier, completion: @escaping (Result<Enabled, SLError>) -> Void) {

        AF.request("\(BASE_URL)/api/aliases/\(id)/toggle", method: .post, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
    
    static func deleteAlias(apiKey: ApiKey, id: Alias.Identifier, completion: @escaping (Result<Any?, SLError>) -> Void) {
   
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
                        deleted.value ? completion(.success(nil)) : completion(.failure(.failedToDelete(anyObject: Alias.self)))
                        
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
    
    static func updateAliasNote(apiKey: ApiKey, id: Alias.Identifier, note: String?, completion: @escaping (Result<Any?, SLError>) -> Void) {
   
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .put, parameters: ["note": note ?? ""], encoding: JSONEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).response { response in
            
            switch response.result {
            case .success(_):
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
    
    static func getAlias(apiKey: ApiKey, id: Alias.Identifier, completion: @escaping (Result<Alias, SLError>) -> Void) {

        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
}

// MARK: - Contact
extension SLApiService {
    static func fetchContacts(apiKey: ApiKey, aliasId: Alias.Identifier, page: Int, completion: @escaping (Result<[Contact], SLError>) -> Void) {
  
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/contacts?page_id=\(page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
                    
                case 400: completion(.failure(.badRequest(description: "page_id must be provided in request query.")))
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
    
    static func createContact(apiKey: ApiKey, aliasId: Alias.Identifier, email: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["contact" : email]
        
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/contacts", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).response { response in
            
            switch response.result {
            case .success(_):
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
    
    static func deleteContact(apiKey: ApiKey, id: Contact.Identifier, completion: @escaping (Result<Any?, SLError>) -> Void) {
        
        AF.request("\(BASE_URL)/api/contacts/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
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
                        deleted.value ? completion(.success(nil)) : completion(.failure(.failedToDelete(anyObject: Contact.self)))
                        
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

// MARK: - IAP
extension SLApiService {
    static func processPayment(apiKey: ApiKey, receiptData: String, completion: @escaping (Result<Any?, SLError>) -> Void) {
        let parameters = ["receipt_data": receiptData]
        
        AF.request("\(BASE_URL)/api/apple/process_payment", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).response { response in
            
            switch response.result {
            case .success(_):
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
    static func fetchMailboxes(apiKey: ApiKey, completion: @escaping (Result<[Mailbox], SLError>) -> Void) {
        AF.request("\(BASE_URL)/api/mailboxes", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: apiKey.toHeaders(), interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let mailboxes = try [Mailbox](data: data)
                        completion(.success(mailboxes))
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
