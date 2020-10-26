//
//  UIAlertController+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

extension UIAlertController {
    @discardableResult
    func addTextView(initialText: String? = nil) -> UITextView {
        let textView = UITextView()
        textView.text = initialText

        let textViewController = UIViewController()
        textViewController.view.addSubview(textView)
        textView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 10, bottom: 8, right: 10))
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor

        setValue(textViewController, forKey: "contentViewController")
        view.constrainHeight(constant: 200)

        return textView
    }
}
