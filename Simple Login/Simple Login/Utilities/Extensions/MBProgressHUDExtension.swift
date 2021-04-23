//
//  MBProgressHUDExtension.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 23/04/2021.
//  Copyright © 2021 SimpleLogin. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    static func showCheckmarkHud(in view: UIView, text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView
        hud.customView = UIImageView(image: UIImage(named: "Checkmark"))
        hud.label.numberOfLines = 3
        hud.label.text = text
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.1)
        hud.hide(animated: true, afterDelay: 1)
    }
}
