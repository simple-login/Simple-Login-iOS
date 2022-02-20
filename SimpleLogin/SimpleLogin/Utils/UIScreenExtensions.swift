//
//  UIScreenExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import Foundation
import UIKit

extension UIScreen {
    var minLength: CGFloat {
        min(bounds.width, bounds.height)
    }
}
