//
//  DeletedAlias.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class DeletedAlias {
    let email: String
    let deletionTimestamp: TimeInterval
    
    lazy var deletionTimestampString: String = {
        let date = Date(timeIntervalSince1970: deletionTimestamp)
        let preciseDateAndTime = preciseDateFormatter.string(from: date)
        let (value, unit) =  date.distanceFromNow()
        return "Deleted on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()
    
    init() {
        let randomId = Array(0...100).randomElement()!
        email = "example\(randomId)"
        let randomHour = Array(0...10).randomElement()!
        deletionTimestamp = TimeInterval(1578697200 + randomHour * 86400)
    }
}
