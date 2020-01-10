//
//  AppDelegate.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        do {
            try SLKeychainService.setApiKey("fwtdafjhcclxkoreayetkmhulscpqsceysgojqcklsimbacaqtouqyzmjikm")
        } catch {
            print("Error setting api key to keychain")
        }
        #endif
        return true
    }
}

