//
//  UIView+Utitlities.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 05/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }

    func animateHidden(_ hidden: Bool) {
        guard isHidden != hidden else { return }
        isHidden = false
        // swiftlint:disable:next multiline_arguments
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.alpha = isHidden ? 0 : 1
        } completion: { [unowned self] _ in
            self.isHidden = hidden
        }
    }
}
