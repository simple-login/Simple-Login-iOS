//
//  SLApiService.swift
//  Share Extension
//
//  Created by Thanh-Nhon Nguyen on 19/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Login
final class SLApiService {
    
    static func fetchUserOptions(apiKey: String, hostname: String, completion: @escaping (_ userOptions: UserOptions?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        
        AF.request("\(BASE_URL)/api/v3/alias/options?hostname=\(hostname)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let data = response.data else {
                completion(nil, SLError.noData)
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownResponseStatusCode)
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
            default: completion(nil, SLError.unknownErrorWithStatusCode(statusCode: statusCode))
            }
        }
    }
    
    static func createNewAlias(apiKey: String, prefix: String, suffix: String, note: String?, completion: @escaping (_ newlyCreatedAlias: String?, _ error: SLError?) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey]
        var parameters = ["alias_prefix" : prefix, "alias_suffix" : suffix]
        
        if let note = note {
            parameters["note"] = note
        }
        
        AF.request("\(BASE_URL)/api/alias/custom/new", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            
            guard let statusCode = response.response?.statusCode else {
                completion(nil, SLError.unknownResponseStatusCode)
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
                    
                    if let jsonDictionary = jsonDictionary, let alias = jsonDictionary["email"] as? String {
                        completion(alias, nil)
                    }
                    
                } catch {
                    completion(nil, SLError.failToSerializeJSONData)
                }
                
            case 401: completion(nil, SLError.invalidApiKey)
            case 409: completion(nil, SLError.duplicatedAlias)
            case 500: completion(nil, SLError.internalServerError)
            case 502: completion(nil, SLError.badGateway)
            default: completion(nil, SLError.unknownErrorWithStatusCode(statusCode: statusCode))
            }
        }
    }
}
