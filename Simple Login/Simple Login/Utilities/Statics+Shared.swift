//
//  Statics+Shared.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

// Shared with Share Extension
let preciseDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM yyyy 'at' HH:mm"
    return dateFormatter
}()
