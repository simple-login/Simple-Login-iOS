//
//  ReachabilityObserver.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 13/03/2022.
//

import Foundation
import Reachability
import SwiftUI

final class ReachabilityObserver: ObservableObject {
    private let reachability = try? Reachability()
    @Published private(set) var reachable = true

    init() {
        reachability?.whenReachable = { [unowned self] _ in
            reachable = true
        }

        reachability?.whenUnreachable = { [unowned self] _ in
            reachable = false
        }

        try? reachability?.startNotifier()
    }
}
