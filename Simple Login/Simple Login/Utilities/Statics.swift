//
//  Statics.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 09/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

let BASE_WEBSITE_URL = "https://simplelogin.io"

let CORNER_RADIUS: CGFloat = 2.0

var hasTopNotch: Bool {
    if #available(iOS 13.0,  *) {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
    } else{
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}

let preciseDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM yyyy 'at' HH:mm"
    return dateFormatter
}()
