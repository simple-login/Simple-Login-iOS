//
//  KeyboardExtensionMode.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/02/2022.
//

import Foundation

enum KeyboardExtensionMode: Int, CaseIterable {
    case pinned = 0, all = 1

    var title: String {
        switch self {
        case .pinned:
            return "Pinned alises"
        case .all:
            return "All aliases"
        }
    }
}
