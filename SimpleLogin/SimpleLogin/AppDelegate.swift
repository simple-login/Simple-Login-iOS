//
//  AppDelegate.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 10/01/2022.
//

import SwiftyStoreKit
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIView.appearance(whenContainedInInstancesOf:
                            [UIAlertController.self]).tintColor = .slPurple
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                default: break
                }
            }
        }
        return true
    }
}
