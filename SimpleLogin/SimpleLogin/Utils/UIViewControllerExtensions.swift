//
//  UIAlertControllerExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 14/05/2022.
//

import UIKit

extension UIViewController {
    func alert(error: Error, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error occured",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
