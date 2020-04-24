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
final class SLApiService {
    static func login(email: String, password: String, completion: @escaping (Result<UserLogin, SLError>) -> Void) {
        let parameters = ["email" : email, "password" : password, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(.failure(.noData))
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.unknownResponseStatusCode))
                return
            }
            
            switch statusCode {
            case 200:
                do {
                    let userLogin = try UserLogin(fromData: data)
                    completion(.success(userLogin))
                } catch let error {
                    completion(.failure(error as! SLError))
                }
                
            case 400: completion(.failure(.emailOrPasswordIncorrect))
            case 500: completion(.failure(.internalServerError))
            case 502: completion(.failure(.badGateway))
            default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
            }
        }
    }
    
    static func verifyMFA(mfaKey: String, mfaToken: String, completion: @escaping (Result<ApiKey, SLError>) -> Void) {
        let parameters = ["mfa_token" : mfaToken, "mfa_key" : mfaKey, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/mfa", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(.failure(.noData))
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.unknownResponseStatusCode))
                return
            }
            
            switch statusCode {
            case 200:
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    
                    if let apiKey = jsonDictionary?["api_key"] as? String {
                        completion(.success(apiKey))
                    } else {
                        completion(.failure(.failToSerializeJSONData))
                    }
                    
                } catch {
                    completion(.failure(.unknownError(description: error.localizedDescription)))
                }
                
            case 400: completion(.failure(.wrongTotpToken))
            case 500: completion(.failure(.internalServerError))
            case 502: completion(.failure(.badGateway))
            default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
            }
        }
    }
    
    static func forgotPassword(email: String, completion: @escaping () -> Void) {
        AF.request("\(BASE_URL)/api/auth/forgot_password", method: .post, parameters: ["email": email], encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            completion()
        }
    }
    
    static func fetchUserInfo(apiKey: ApiKey, completion: @escaping (Result<UserInfo, SLError>) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/user_info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(.failure(.noData))
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.unknownResponseStatusCode))
                return
            }
            
            switch statusCode {
            case 200:
                do {
                    let userInfo = try UserInfo(fromData: data)
                    completion(.success(userInfo))
                } catch let error as SLError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.unknownError(description: error.localizedDescription)))
                }
                
            case 401: completion(.failure(.invalidApiKey))
            case 500: completion(.failure(.internalServerError))
            case 502: completion(.failure(.badGateway))
            default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
            }
        }
    }
    
    static func fetchUserOptions(apiKey: String, completion: @escaping (_ userOptions: UserOptions?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/v3/alias/options", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(nil, SLError.noData)
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                do {
                    let userOptions = try UserOptions(fromData: data)
                    completion(userOptions, nil)
                } catch let error {
                    completion(nil, error as? SLError)
                }
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}

// MARK: - Sign Up
extension SLApiService {
    static func signUp(email: String, password: String, completion: @escaping (_ error: SLError?) -> Void) {
        let parameters = ["email" : email, "password" : password]
        
        AF.request("\(BASE_URL)/api/auth/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(SLError.noData)
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200: completion(nil)
                
            case 400:
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let error = jsonDictionary?["error"] as? String {
                        completion(SLError.badRequest(description: error))
                    } else {
                        completion(SLError.failToSerializeJSONData)
                    }
                    
                } catch {
                    completion(SLError.failToSerializeJSONData)
                }
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func verifyEmail(email: String, code: String, completion: @escaping (_ error: SLError?) -> Void) {
        let parameters = ["email" : email, "code" : code]
        
        AF.request("\(BASE_URL)/api/auth/activate", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            guard let _ = response.data else {
                completion(SLError.noData)
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200: completion(nil)
                
            case 400: completion(SLError.wrongVerificationCode)
            case 410: completion(SLError.reactivationNeeded)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func reactivate(email: String, completion: @escaping (_ error: SLError?) -> Void) {
        let parameters = ["email" : email]
        
        AF.request("\(BASE_URL)/api/auth/reactivate", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            guard let _ = response.data else {
                completion(SLError.noData)
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200: completion(nil)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}

// MARK: - Alias
extension SLApiService {
    static func fetchAliases(apiKey: String, page: Int, searchTerm: String? = nil, completion: @escaping (_ aliases: [Alias]?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        let method: HTTPMethod
        let parameters: [String: Any]?
        if let searchTerm = searchTerm {
            parameters = ["query": searchTerm]
            method = .post
        } else {
            parameters = nil
            method = .get
        }
        
        
        AF.request("\(BASE_URL)/api/v2/aliases?page_id=\(page)", method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let aliasDictionaries = jsonDictionary?["aliases"] as? [[String : Any]] {
                        var aliases: [Alias] = []
                        try aliasDictionaries.forEach { (dictionary) in
                            do {
                                try aliases.append(Alias(fromDictionary: dictionary))
                            } catch let error as SLError {
                                completion(nil, error)
                                return
                            }
                        }
                        
                        completion(aliases, nil)
                        
                    } else {
                        completion(nil, SLError.failToSerializeJSONData)
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 400: completion(nil, SLError.badRequest(description: "page_id must be provided in request query."))
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func fetchAliasActivities(apiKey: String, aliasId: Alias.Identifier, page: Int, completion: @escaping (_ activities: [AliasActivity]?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/activities?page_id=\(page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let activityDictionaries = jsonDictionary?["activities"] as? [[String : Any]] {
                        var activities: [AliasActivity] = []
                        try activityDictionaries.forEach { (dictionary) in
                            do {
                                try activities.append(AliasActivity(fromDictionary: dictionary))
                            } catch let error as SLError {
                                completion(nil, error)
                                return
                            }
                        }
                        
                        completion(activities, nil)
                        
                    } else {
                        completion(nil, SLError.failToSerializeJSONData)
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 400: completion(nil, SLError.badRequest(description: "page_id must be provided in request query."))
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func createNewAlias(apiKey: String, prefix: String, suffix: String, note: String?, completion: @escaping (_ newlyCreatedAlias: Alias?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        var parameters = ["alias_prefix" : prefix, "alias_suffix" : suffix]
        
        if let note = note {
            parameters["note"] = note
        }
        
        AF.request("\(BASE_URL)/api/alias/custom/new", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 201:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let jsonDictionary = jsonDictionary {
                        do {
                            let alias = try Alias(fromDictionary: jsonDictionary)
                            completion(alias, nil)
                        } catch let error as SLError {
                            completion(nil, error)
                        }
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 409: completion(nil, SLError.duplicatedAlias)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func randomAlias(apiKey: String, randomMode: RandomMode, completion: @escaping (_ newlyCreatedAlias: Alias?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/alias/random/new?mode=\(randomMode.rawValue)", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 201:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let jsonDictionary = jsonDictionary {
                        do {
                            let alias = try Alias(fromDictionary: jsonDictionary)
                            completion(alias, nil)
                        } catch let error as SLError {
                            completion(nil, error)
                        }
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func toggleAlias(apiKey: String, id: Alias.Identifier, completion: @escaping (_ enabled: Bool?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(id)/toggle", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let enabled = jsonDictionary?["enabled"] as? Bool {
                        completion(enabled, nil)
                    } else {
                        completion(nil, SLError.failToParseObject(objectName: "toggle alias status"))
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func deleteAlias(apiKey: String, id: Alias.Identifier, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let deleted = jsonDictionary?["deleted"] as? Bool {
                        deleted ? completion(nil) : completion(SLError.failToDelete(objectName: "Alias"))
                    } else {
                        completion(SLError.failToParseObject(objectName: "delete alias"))
                    }
                    
                } catch {
                    completion(SLError.failToSerializeJSONData)
                }
                
            case 401: completion(SLError.invalidApiKey)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func updateAliasNote(apiKey: String, id: Alias.Identifier, note: String?, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .put, parameters: ["note": note ?? ""], encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200: completion(nil)
            case 401: completion(SLError.invalidApiKey)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func getAlias(apiKey: String, id: Alias.Identifier, completion: @escaping (_ alias: Alias?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let jsonDictionary = jsonDictionary {
                        do {
                            let alias = try Alias(fromDictionary: jsonDictionary)
                            completion(alias, nil)
                        } catch let error as SLError {
                            completion(nil, error)
                        }
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}

// MARK: - Contact
extension SLApiService {
    static func fetchContacts(apiKey: String, aliasId: Alias.Identifier, page: Int, completion: @escaping (_ contacts: [Contact]?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/contacts?page_id=\(page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(nil, SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let contactDictionaries = jsonDictionary?["contacts"] as? [[String : Any]] {
                        var contacts: [Contact] = []
                        try contactDictionaries.forEach { (dictionary) in
                            do {
                                try contacts.append(Contact(fromDictionary: dictionary))
                            } catch let error as SLError {
                                completion(nil, error)
                                return
                            }
                        }
                        
                        completion(contacts, nil)
                        
                    } else {
                        completion(nil, SLError.failToSerializeJSONData)
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 400: completion(nil, SLError.badRequest(description: "page_id must be provided in request query."))
            case 401: completion(nil, SLError.invalidApiKey)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func createContact(apiKey: String, aliasId: Alias.Identifier, email: String, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        let parameters = ["contact" : email]
        
        AF.request("\(BASE_URL)/api/aliases/\(aliasId)/contacts", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 201: completion(nil)
            case 401: completion(SLError.invalidApiKey)
            case 409: completion(SLError.duplicatedContact)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func deleteContact(apiKey: String, id: Int, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/contacts/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200:
                guard let data = response.data else {
                    completion(SLError.noData)
                    return
                }
                
                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                    
                    if let deleted = jsonDictionary?["deleted"] as? Bool {
                        deleted ? completion(nil) : completion(SLError.failToDelete(objectName: "Contact"))
                    } else {
                        completion(SLError.failToParseObject(objectName: "delete contact"))
                    }
                    
                } catch {
                    completion(SLError.failToSerializeJSONData)
                }
                
            case 401: completion(SLError.invalidApiKey)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}

// MARK: - IAP
extension SLApiService {
    static func processPayment(apiKey: String, receiptData: String, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        let parameters = ["receipt_data": receiptData]
        
        AF.request("\(BASE_URL)/api/apple/process_payment", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 200: completion(nil)
            case 401: completion(SLError.invalidApiKey)
            case 500: completion(SLError.internalServerError)
            case 502: completion(SLError.badGateway)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}
