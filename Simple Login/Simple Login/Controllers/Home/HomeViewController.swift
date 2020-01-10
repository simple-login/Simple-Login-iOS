//
//  HomeViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SideMenu

final class HomeViewController: UIViewController {
    var userInfo: UserInfo?
    
    deinit {
        print("HomeViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSideMenu()
    }
}

// MARK: - Side Menu
extension HomeViewController {
    private func setUpSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sideMenuNavigationController as SideMenuNavigationController:
            sideMenuNavigationController.presentationStyle = .menuSlideIn
            sideMenuNavigationController.presentationStyle.presentingEndAlpha = 0.7
            
            let leftMenuViewController = sideMenuNavigationController.viewControllers[0] as? LeftMenuViewController
            leftMenuViewController?.userInfo = userInfo
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                sideMenuNavigationController.menuWidth = UIScreen.main.bounds.size.width * 3 / 4
            }
            
        default: return
        }
    }
}
