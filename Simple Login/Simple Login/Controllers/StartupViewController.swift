//
//  StartupViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class StartupViewController: UIViewController {
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var retryButton: UIButton!
    
    deinit {
        print("StartupViewController is deallocated")
    }
    
    private var apiKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let apiKey = SLKeychainService.getApiKey() {
            self.apiKey = apiKey
            checkApiKeyAndProceed()
        } else {
            presentLoginViewController()
        }
    }
    
    @IBAction private func retry() {
        checkApiKeyAndProceed()
    }
    
    private func checkApiKeyAndProceed() {
        guard let apiKey = apiKey else {
            presentLoginViewController()
            return
        }
        
        messageLabel.text = "Connecting to server..."
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        retryButton.isHidden = true
        
        SLApiService.fetchUserInfo(apiKey, completion: { [weak self] (userInfo, error) in
            guard let self = self else { return }
            
            self.activityIndicatorView.isHidden = true
            self.activityIndicatorView.stopAnimating()
            
            if let error = error {
                self.messageLabel.text = "Error occured: \(error.description)"
                self.retryButton.isHidden = false
                
                switch error {
                case .invalidApiKey:
                    self.presentLoginViewController()
                    
                default: return
                }
                
            } else if let userInfo = userInfo {
                self.presentHomeNavigationController(userInfo)
            }
        })
    }
    
    private func presentHomeNavigationController(_ userInfo: UserInfo) {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        guard let homeNavigationController = homeStoryboard.instantiateViewController(withIdentifier: "HomeNavigationViewController") as? UINavigationController else {
            fatalError("Can not instantiate HomeNavigationViewController")
        }
        
        guard let homeViewController = homeNavigationController.topViewController as? HomeViewController  else {
            fatalError("Can not instantiate HomeViewController")
        }
        
        homeViewController.userInfo = userInfo
        homeNavigationController.modalPresentationStyle = .fullScreen
        present(homeNavigationController, animated: true, completion: nil)
    }
    
    private func presentLoginViewController() {
        print(#function)
    }
}
