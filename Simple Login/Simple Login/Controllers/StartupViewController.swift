//
//  StartupViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MBProgressHUD

final class StartupViewController: UIViewController {
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    
    deinit {
        print("StartupViewController is deallocated")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkApiKeyAndProceed()
    }
    
    @IBAction private func retry() {
        checkApiKeyAndProceed()
    }
    
    private func checkApiKeyAndProceed() {
        guard let apiKey = SLKeychainService.getApiKey() else {
            presentLoginViewController()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        messageLabel.text = "Connecting to server..."
        retryButton.alpha = 0
        retryButton.isEnabled = false
        
        SLApiService.fetchUserInfo(apiKey, completion: { [weak self] (userInfo, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                self.messageLabel.text = "Error occured: \(error.description)"
                self.retryButton.alpha = 1
                self.retryButton.isEnabled = true
                self.presentLoginViewController()
                
            } else if let userInfo = userInfo {
                self.presentHomeNavigationController(userInfo)
            }
        })
    }
    
    private func presentHomeNavigationController(_ userInfo: UserInfo) {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        guard let homeNavigationController = homeStoryboard.instantiateViewController(withIdentifier: "HomeNavigationController") as? HomeNavigationController else {
            fatalError("Can not instantiate HomeNavigationController")
        }

        homeNavigationController.userInfo = userInfo
        homeNavigationController.modalPresentationStyle = .fullScreen
        
        present(homeNavigationController, animated: true) { [unowned self] in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func presentLoginViewController() {
        let loginViewController = LoginViewController.instantiate(storyboardName: "Login")
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }
}
