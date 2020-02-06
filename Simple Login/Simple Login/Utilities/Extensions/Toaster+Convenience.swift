//
//  Toaster+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import Toaster
import OAuth2

extension Toast {
    class func displayShortly(message: String) {
        ToastCenter.default.cancelAll()
        Toast(text: message, duration: Delay.short).show()
    }
    
    class func displayLongly(message: String) {
        ToastCenter.default.cancelAll()
        Toast(text: message, duration: Delay.long).show()
    }
    
    class func displayErrorRetrieveingApiKey() {
        Toast.displayShortly(message: "Error retrieving API key from keychain")
    }
    
    class func displayError(_ error: CustomStringConvertible) {
        Toast.displayShortly(message: "Error occured: \(error.description)")
    }
}
