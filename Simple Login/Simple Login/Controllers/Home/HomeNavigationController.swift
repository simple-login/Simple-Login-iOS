//
//  HomeNavigationController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SideMenu
import Toaster
import FirebaseAnalytics

final class HomeNavigationController: UINavigationController, Storyboarded {
    private var aliasViewController: AliasViewController?
    private var directoryViewController: DirectoryViewController?
    private var customDomainViewController: CustomDomainViewController?
    private var settingsViewController: SettingsViewController?
    private var aboutViewController: AboutViewController?

    var userInfo: UserInfo?
    
    private var leftMenuIsShown: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if leftMenuIsShown {
            return .lightContent
        }
        
        return .default
    }
    
    deinit {
        print("HomeNavigationController is deallocated")
        NotificationCenter.default.removeObserver(self, name: .askForReview, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default rootViewController is AliasViewController
        aliasViewController = viewControllers[0] as? AliasViewController
        aliasViewController?.didTapLeftBarButtonItem = { [unowned self] in
            self.toggleLeftMenu()
        }
        
        // Listen to askForReview notification
        NotificationCenter.default.addObserver(forName: .askForReview, object: nil, queue: nil) { [unowned self] _ in
            self.gentlyAskForReview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        if viewControllers[0] != aliasViewController {
            aliasViewController = nil
        }
        
        if viewControllers[0] != directoryViewController {
            directoryViewController = nil
        }
        
        if viewControllers[0] != customDomainViewController {
            customDomainViewController = nil
        }
        
        if viewControllers[0] != settingsViewController {
            settingsViewController = nil
        }
        
        if viewControllers[0] != aboutViewController {
            aboutViewController = nil
        }
    }
    
    private func toggleLeftMenu() {
        performSegue(withIdentifier: "showLeftMenu", sender: self)
    }
    
    private func dismissLeftMenu() {
        SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sideMenuNavigationController as SideMenuNavigationController:
            SideMenuManager.default.leftMenuNavigationController = sideMenuNavigationController
            //SideMenuManager.default.addPanGestureToPresent(toView: navigationBar)
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
            
            sideMenuNavigationController.presentationStyle = .menuSlideIn
            sideMenuNavigationController.presentationStyle.presentingEndAlpha = 0.7
            sideMenuNavigationController.statusBarEndAlpha = 0.0
            sideMenuNavigationController.leftSide = true
            sideMenuNavigationController.sideMenuDelegate = self
            
            let leftMenuViewController = sideMenuNavigationController.viewControllers[0] as? LeftMenuViewController
            leftMenuViewController?.userInfo = userInfo
            leftMenuViewController?.delegate = self
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                sideMenuNavigationController.menuWidth = UIScreen.main.bounds.size.width * 3 / 4
            }
            
        default: return
        }
    }
    
    private func gentlyAskForReview() {
        let alert = UIAlertController(title: "Rate SimpleLogin", message: "If you find SimpleLogin useful, please take a moment to make a review on App Store.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Take me to App Store", style: .default) { (action) in
            self.openAppStore()
            UserDefaults.setDidMakeAReview()
            Analytics.logEvent("made_a_review_from_alert", parameters: nil)
        }
        alert.addAction(okayAction)
        
        let cancelAction = UIAlertAction(title: "Remind me later", style: .cancel) { (action) in
            Analytics.logEvent("review_later", parameters: nil)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func openAppStore() {
        guard let url = URL(string: "https://itunes.apple.com/app/id1494359858?action=write-review") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - LeftMenuViewControllerDelegate
extension HomeNavigationController: LeftMenuViewControllerDelegate {
    
    func didSelectAlias() {
        if aliasViewController == nil {
            aliasViewController = AliasViewController.instantiate(storyboardName: "Home")
            
            aliasViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let aliasViewController = aliasViewController else { return }
        
        viewControllers = [aliasViewController]
        dismissLeftMenu()
    }
    
    func didSelectDirectory() {
        if directoryViewController == nil {
            directoryViewController = DirectoryViewController.instantiate(storyboardName: "Directory")
            
            directoryViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let directoryViewController = directoryViewController else { return }
        
        viewControllers = [directoryViewController]
        dismissLeftMenu()
    }
    
    func didSelectCustomDomain() {
        if customDomainViewController == nil {
            customDomainViewController = CustomDomainViewController.instantiate(storyboardName: "CustomDomain")
            
            customDomainViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let customDomainViewController = customDomainViewController else { return }
        
        viewControllers = [customDomainViewController]
        dismissLeftMenu()
    }
    
    func didSelectSettings() {
        if settingsViewController == nil {
            settingsViewController = SettingsViewController.instantiate(storyboardName: "Settings")
            settingsViewController?.userInfo = userInfo
            settingsViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let settingsViewController = settingsViewController else { return }
        
        viewControllers = [settingsViewController]
        dismissLeftMenu()
    }
    
    func didSelectAbout() {
        if aboutViewController == nil {
            aboutViewController = AboutViewController.instantiate(storyboardName: "About")
            
            aboutViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let aboutViewController = aboutViewController else { return }
    
        viewControllers = [aboutViewController]
        dismissLeftMenu()
    }
    
    func didSelectRateUs() {
        openAppStore()
        Analytics.logEvent("made_a_review_from_left_menu", parameters: nil)
    }
    
    func didSelectSignOut() {
        let alert = UIAlertController(title: "You will be signed out", message: "Please confirm", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes, sign me out", style: .destructive) { [unowned self] _ in
            do {
                try SLKeychainService.removeApiKey()
                SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
                Analytics.logEvent("sign_out_success", parameters: nil)
                
            } catch {
                Toast.displayShortly(message: "Error removing API key from keychain")
                Analytics.logEvent("sign_out_error", parameters: nil)
            }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            Analytics.logEvent("sign_out_cancel", parameters: nil)
        }
        alert.addAction(cancelAction)
        
        SideMenuManager.default.leftMenuNavigationController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - SideMenuNavigationControllerDelegate
extension HomeNavigationController: SideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        leftMenuIsShown = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        leftMenuIsShown = false
        setNeedsStatusBarAppearanceUpdate()
    }
}
