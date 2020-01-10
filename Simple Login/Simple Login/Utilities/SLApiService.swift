//
//  SLApiService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import Alamofire

final class SLApiService {
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
