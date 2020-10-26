//
//  Notification+Name.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 05/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let askForReview = Notification.Name("AskForReview")
    static let applicationDidBecomeActive = Notification.Name("applicationDidBecomeActive")
    static let purchaseSuccessfully = Notification.Name("purchaseSuccessfully")
    static let errorRetrievingApiKeyFromKeychain = Notification.Name("errorRetrievingApiKeyFromKeychain")
}
