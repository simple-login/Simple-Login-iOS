//
//  HomeNavigationController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SideMenu

final class HomeNavigationController: UINavigationController {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default rootViewController is AliasViewController
        aliasViewController = viewControllers[0] as? AliasViewController
        aliasViewController?.didTapLeftBarButtonItem = { [unowned self] in
            self.toggleLeftMenu()
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
            SideMenuManager.default.addPanGestureToPresent(toView: navigationBar)
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
}

// MARK: - LeftMenuViewControllerDelegate
extension HomeNavigationController: LeftMenuViewControllerDelegate {
    
    func didSelectAlias() {
        if aliasViewController == nil {
            aliasViewController = storyboard?.instantiateViewController(withIdentifier: "AliasViewController") as? AliasViewController
            
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
            directoryViewController = storyboard?.instantiateViewController(withIdentifier: "DirectoryViewController") as? DirectoryViewController
            
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
            customDomainViewController = storyboard?.instantiateViewController(withIdentifier: "CustomDomainViewController") as? CustomDomainViewController
            
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
            settingsViewController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
            
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
            aboutViewController = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController
            
            aboutViewController?.didTapLeftBarButtonItem = { [unowned self] in
                self.toggleLeftMenu()
            }
        }
        
        guard let aboutViewController = aboutViewController else { return }
    
        viewControllers = [aboutViewController]
        dismissLeftMenu()
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
