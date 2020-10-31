//
//  LatestActivity.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 20/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct LatestActivity: Decodable {
    let action: AliasActivity.Action
    let contact: ContactLite
    let timestamp: TimeInterval
}
