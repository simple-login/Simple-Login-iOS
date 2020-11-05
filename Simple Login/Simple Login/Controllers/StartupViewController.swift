//
//  StartupViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import Toaster
import UIKit

final class StartupViewController: BaseViewController {
    private var homeNavigationController: HomeNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        SLClient.shared.refreshBaseUrl()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfully),
                                               name: .purchaseSuccessfully,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleErrorRetrievingApiKeyFromKeychain),
                                               name: .errorRetrievingApiKeyFromKeychain,
                                               object: nil)
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

    private func checkApiKeyAndProceed() {
        guard let apiKey = SLKeychainService.getApiKey() else {
            presentLoginViewController()
            return
        }

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = "Connecting to server..."
        hud.offset = CGPoint(x: 0.0, y: MBProgressMaxOffset)

        SLClient.shared.fetchUserInfo(apiKey: apiKey) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                hud.hide(animated: true)

                switch result {
                case .success(let userInfo):
                    self.presentHomeNavigationController(userInfo)

                case .failure(let error):
                    switch error {
                    case .internalServerError:
                        self.presentRetryAlert(error: error)

                    default:
                        Toast.displayLongly(message: "Error occured: \(error.description)")
                        self.presentLoginViewController()
                    }
                }
            }
        }
    }

    private func presentHomeNavigationController(_ userInfo: UserInfo) {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)

        // swiftlint:disable:next line_length
        guard let homeNavigationController = homeStoryboard.instantiateViewController(withIdentifier: "HomeNavigationController") as? HomeNavigationController else {
            fatalError("Can not instantiate HomeNavigationController")
        }

        homeNavigationController.userInfo = userInfo
        homeNavigationController.modalPresentationStyle = .fullScreen

        self.homeNavigationController = homeNavigationController

        present(homeNavigationController, animated: true)
    }

    private func presentLoginViewController() {
        let loginNavigationViewController = LoginNavigationViewController.instantiate(storyboardName: "Login")
        loginNavigationViewController.modalPresentationStyle = .fullScreen
        present(loginNavigationViewController, animated: true, completion: nil)
    }

    private func presentRetryAlert(error: SLError) {
        let alert = UIAlertController(title: "Error occured", message: error.description, preferredStyle: .alert)

        let retryAction = UIAlertAction(title: "Retry", style: .default) { [unowned self] _ in
            self.checkApiKeyAndProceed()
        }
        alert.addAction(retryAction)

        present(alert, animated: true, completion: nil)
    }

    @objc
    private func handlePurchaseSuccessfully() {
        homeNavigationController?.dismiss(animated: true, completion: nil)
    }

    @objc
    private func handleErrorRetrievingApiKeyFromKeychain() {
        try? SLKeychainService.removeApiKey()
        homeNavigationController?.dismiss(animated: true, completion: nil)
    }
}
