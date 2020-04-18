//
//  SKProduct+RegularPrice.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyISOCode
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
