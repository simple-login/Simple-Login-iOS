//
//  BaseApiKeyViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class BaseApiKeyViewController: BaseViewController {
    var apiKey: ApiKey!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveApiKey()
    }
    
    private func retrieveApiKey() {
        if let apiKey = SLKeychainService.getApiKey() {
            self.apiKey = apiKey
        } else {
            #if HOSTAPP
            let alert = UIAlertController(title: "API key unknown", message: "Can not read API key from Keychain.", preferredStyle: .alert)
            
            // Send a notification to StartupViewController to dismiss HomeNavigationController
            let closeAction = UIAlertAction(title: "Close", style: .default) { _ in
                NotificationCenter.default.post(name: .errorRetrievingApiKeyFromKeychain, object: nil)
            }
            alert.addAction(closeAction)
            
            present(alert, animated: true, completion: nil)
            #else
            let alert = UIAlertController(title: "Sign-in required", message: "You have to sign in before using this feature", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Close", style: .cancel) { (_) in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
            
            alert.addAction(closeAction)
            present(alert, animated: true, completion: nil)
            #endif
        }
    }
}
