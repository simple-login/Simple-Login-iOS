//
//  Action.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/10/2021.
//

import SimpleLoginPackage
import SwiftUI

extension ActivityAction {
    var iconSystemName: String {
        switch self {
        case .bounced, .block: return "nosign"
        case .reply: return "arrowshape.turn.up.left.fill"
        case .forward: return "paperplane.fill"
        }
    }

    var color: Color {
        switch self {
        case .bounced, .block: return .red
        case .reply: return .blue
        case .forward: return .green
        }
    }
}
