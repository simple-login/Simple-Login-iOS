//
//  RandomMode.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 07/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum RandomMode: String, CustomStringConvertible, Decodable {
    case uuid = "uuid", word = "word"

    var description: String {
        switch self {
        case .uuid: return "Based on UUID"
        case .word: return "Based on random words"
        }
    }
}
