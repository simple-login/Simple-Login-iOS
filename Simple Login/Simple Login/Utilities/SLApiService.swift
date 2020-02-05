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
    
    static func fetchUserOptions(apiKey: String, hostname: String, completion: @escaping (_ userOptions: UserOptions?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]

        AF.request("\(BASE_URL)/api/v2/alias/options?hostname=\(hostname)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in

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
    
    static func createNewAlias(apiKey: String, prefix: String, suffix: String, completion: @escaping (_ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        let parameters = ["alias_prefix" : prefix, "alias_suffix" : suffix]
    
        AF.request("\(BASE_URL)/api/alias/custom/new", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in

            guard let statusCode = response.response?.statusCode else {
                completion(SLError.unknownError(description: "error code unknown"))
                return
            }
            
            switch statusCode {
            case 201: completion(nil)
            case 409: completion(SLError.duplicatedAlias)
            default: completion(SLError.unknownError(description: "error code \(statusCode)"))
            }
        }
    }
}
