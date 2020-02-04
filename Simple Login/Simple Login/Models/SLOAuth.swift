//
//  SLOAuth.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

fileprivate let slOAuthDictionary: NSDictionary = {
    let path = Bundle.main.path(forResource: "SLOAuth", ofType: "plist")!
    return NSDictionary(contentsOfFile: path)!
}()

struct SLOAuth {
    private init() {}
    
    struct Github {
        private init() {}
        private static let dictionary = slOAuthDictionary["Github"] as! [String : String]
        static let clientId = dictionary["client_id"]!
        static let clientSecret = dictionary["client_secret"]!
    }
    
    struct Google {
        private init() {}
        private static let dictionary = slOAuthDictionary["Google"] as! [String : String]
        static let clientId = dictionary["client_id"]!
    }
}

enum SLOAuthService: String {
    case github = "github"
    case google = "google"
    case facebook = "facebook"
}
