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
    static func login(email: String, password: String, completion: @escaping (_ userLogin: UserLogin?, _ error: SLError?) -> Void) {
        let parameters = ["email" : email, "password" : password, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
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
                    let userLogin = try UserLogin(fromData: data)
                    completion(userLogin, nil)
                } catch let error {
                    completion(nil, error as? SLError)
                }
                
            case 400: completion(nil, SLError.emailOrPasswordIncorrect)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func socialLogin(service: SLOAuthService, accessToken: String, completion: @escaping (_ userLogin: UserLogin?, _ error: SLError?) -> Void) {
        let parameters = ["\(service.rawValue)_token" : accessToken, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/\(service.rawValue)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
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
                    let userLogin = try UserLogin(fromData: data)
                    completion(userLogin, nil)
                } catch let error {
                    completion(nil, error as? SLError)
                }
                
            case 400: completion(nil, SLError.emailOrPasswordIncorrect)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func verifyMFA(mfaKey: String, mfaToken: String, completion: @escaping (_ apiKey: String?, _ error: SLError?) -> Void) {
        let parameters = ["mfa_token" : mfaToken, "mfa_key" : mfaKey, "device" : UIDevice.current.name]
        
        AF.request("\(BASE_URL)/api/auth/mfa", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
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
                    guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let apiKey = jsonDictionary["api_key"] as? String else {
                        completion(nil, SLError.failToSerializeJSONData)
                        return
                    }
                    
                    completion(apiKey, nil)
                    
                } catch let error {
                    completion(nil, error as? SLError)
                }
                
            case 400:
                do {
                    guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let error = jsonDictionary["error"] as? String else {
                        completion(nil, SLError.badRequest(description: "Failed to serialize json"))
                        return
                    }
                    
                    completion(nil, SLError.badRequest(description: error))
                    
                } catch let error {
                    completion(nil, error as? SLError)
                }
                
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func fetchUserInfo(_ apiKey: String, completion: @escaping (_ userInfo: UserInfo?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/user_info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
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
                    let userInfo = try UserInfo(fromData: data)
                    completion(userInfo, nil)
                } catch let error {
                    completion(nil, error as? SLError)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func fetchUserOptions(apiKey: String, completion: @escaping (_ userOptions: UserOptions?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/v2/alias/options", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
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
                
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func verifyEmail(email: String, code: String, completion: @escaping (_ error: SLError?) -> Void) {
        let parameters = ["email" : email, "code" : code]
        
        AF.request("\(BASE_URL)/api/auth/activate", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
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
                
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}

// MARK: - Alias
extension SLApiService {
    static func fetchAliases(apiKey: String, page: Int, completion: @escaping (_ aliases: [Alias]?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases?page_id=\(page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
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
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func fetchAliasActivities(apiKey: String, aliasId: Int, page: Int, completion: @escaping (_ activities: [AliasActivity]?, _ error: SLError?) -> Void) {
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
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func createNewAlias(apiKey: String, prefix: String, suffix: String, completion: @escaping (_ newlyCreatedAlias: String?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        let parameters = ["alias_prefix" : prefix, "alias_suffix" : suffix]
        
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
                    
                    if let newlyCreatedAlias = jsonDictionary?["alias"] as? String {
                        completion(newlyCreatedAlias, nil)
                    } else {
                        completion(nil, SLError.failToParseObject(objectName: "newly created alias"))
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 409: completion(nil, SLError.duplicatedAlias)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    
    static func randomAlias(apiKey: String, randomMode: RandomMode, completion: @escaping (_ newlyCreatedAlias: String?, _ error: SLError?) -> Void) {
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
                    
                    if let newlyCreatedAlias = jsonDictionary?["alias"] as? String {
                        completion(newlyCreatedAlias, nil)
                    } else {
                        completion(nil, SLError.failToParseObject(objectName: "newly created alias"))
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func toggleAlias(apiKey: String, id: Int, completion: @escaping (_ enabled: Bool?, _ error: SLError?) -> Void) {
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
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
    
    static func deleteAlias(apiKey: String, id: Int, completion: @escaping (_ deleted: Bool?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/aliases/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
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
                    
                    if let deleted = jsonDictionary?["deleted"] as? Bool {
                        completion(deleted, nil)
                    } else {
                        completion(nil, SLError.failToParseObject(objectName: "delete alias"))
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            default: completion(nil, SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}
