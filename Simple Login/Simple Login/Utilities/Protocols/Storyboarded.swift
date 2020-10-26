//
//  Storyboarded.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 17/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate(storyboardName: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(storyboardName: String) -> Self {
        let storyboardId = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        // swiftlint:disable:next force_cast
        return storyboard.instantiateViewController(withIdentifier: storyboardId) as! Self
    }
}
