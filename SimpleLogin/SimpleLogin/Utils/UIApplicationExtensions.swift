//
//  UIApplicationExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if canOpenURL(url) {
            open(url, options: [:], completionHandler: nil)
        }
    }
}
