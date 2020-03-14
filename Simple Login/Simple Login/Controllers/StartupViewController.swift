//
//  StartupViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

final class StartupViewController: UIViewController {
    
    deinit {
        print("StartupViewController is deallocated")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        if UserDefaults.isFirstRun() {
//            let walkthroughViewController = WalkthroughViewController.instantiate(storyboardName: "Walkthrough")
//            walkthroughViewController.modalPresentationStyle = .fullScreen
//
//            walkthroughViewController.getStarted = { [unowned self] in
//                self.checkApiKeyAndProceed()
//            }
//
//            UserDefaults.firstRunComplete()
//            present(walkthroughViewController, animated: true, completion: nil)
//        } else {
//            checkApiKeyAndProceed()
//        }
//
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
        
        SLApiService.fetchUserInfo(apiKey, completion: { [weak self] (userInfo, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayLongly(message: "Error occured: \(error.description)")
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
