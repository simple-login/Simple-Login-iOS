//
//  AppDelegate.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var loginViewController: LoginViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpUI()
        #if DEBUG
        do {
            //try SLKeychainService.setApiKey("fwtdafjhcclxkoreayetkmhulscpqsceysgojqcklsimbacaqtouqyzmjikm")
            
            try SLKeychainService.removeApiKey()
        } catch {
            print("Error setting api key to keychain")
        }
        #endif
        return true
    }
    
    private func setUpUI () {
        window?.tintColor = SLColor.tintColor
        
        // Toaster's appearance
        ToastView.appearance().backgroundColor = SLColor.textColor
        ToastView.appearance().textColor = SLColor.menuBackgroundColor
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Callback from oauth
        if url.absoluteString.contains("github") {
            loginViewController?.oauthGithub?.handleRedirectURL(url)
        } else if url.absoluteString.contains("com.googleusercontent") {
            loginViewController?.oauthGoogle?.handleRedirectURL(url)
        }
    
        return true
    }
}
