//
//  AppDelegate.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import Firebase
import FacebookCore
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpUI()
        FirebaseApp.configure()
        UserDefaults.registerDefaultValues()
        
        // Facebook Login
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Google login
        GIDSignIn.sharedInstance()?.clientID = "1015607994815-1hsa5rebfojg8ml31mgfum0lm59igbi3.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Callback from oauth
        if url.absoluteString.contains("github") {

        } else if url.absoluteString.contains("com.googleusercontent") {
            return GIDSignIn.sharedInstance()?.handle(url) ?? false
        } else if url.absoluteString.contains("fb") {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }

        
        return true
    }
    
    private func setUpUI () {
        window?.tintColor = SLColor.tintColor
        
        // Toaster's appearance
        ToastView.appearance().backgroundColor = SLColor.textColor
        ToastView.appearance().textColor = SLColor.menuBackgroundColor
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .applicationDidBecomeActive, object: nil)
    }
}

// MARK: - GIDSignInDelegate
extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Toast.displayError(error.localizedDescription)
        } else if let accessToken = user.authentication.accessToken {
            NotificationCenter.default.post(name: .didSignInWithGoogle, object: accessToken)
        }
    }
}
