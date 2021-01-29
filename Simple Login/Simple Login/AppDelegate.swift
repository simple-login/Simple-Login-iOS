//
//  AppDelegate.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import SwiftyStoreKit
import Toaster
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // swiftlint:disable:next line_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpUI()
        setUpStoreKit()
        askForReview()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .applicationDidBecomeActive, object: nil)
    }

    private func setUpUI () {
        window?.tintColor = SLColor.tintColor

        // Toaster's appearance
        ToastView.appearance().backgroundColor = SLColor.textColor
        ToastView.appearance().textColor = SLColor.menuBackgroundColor
    }

    private func setUpStoreKit() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default: break
                }
            }
        }
    }

    private func askForReview() {
        defer {
            UserDefaults.increaseNumberOfSessions()
        }

        let numberOfSessions = UserDefaults.numberOfSessions()
        if (numberOfSessions.isMultiple(of: 20)) && !UserDefaults.didMakeAReview() {
            // Continously ask for review after every 20 usages
            // Prompt 15 seconds after app launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                NotificationCenter.default.post(name: .askForReview, object: nil)
            }
        }
    }
}
