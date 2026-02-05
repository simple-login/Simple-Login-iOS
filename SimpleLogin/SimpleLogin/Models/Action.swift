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
        case .block, .bounced: "nosign"
        case .reply: "arrowshape.turn.up.left.fill"
        case .forward: "paperplane.fill"
        }
    }

    var color: Color {
        switch self {
        case .block, .bounced: .red
        case .reply: .blue
        case .forward: .green
        }
    }

    var title: String {
        switch self {
        case .forward: "Forward"
        case .reply: "Reply"
        case .block: "Block"
        case .bounced: "Bounced"
        }
    }
}
