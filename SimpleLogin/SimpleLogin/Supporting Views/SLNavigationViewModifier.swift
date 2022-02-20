//
//  SLNavigationViewModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 06/02/2022.
//

import Introspect
import SwiftUI

struct SLNavigationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.introspectNavigationController { navigationController in
            navigationController.splitViewController?.preferredPrimaryColumnWidthFraction = 1
            navigationController.splitViewController?.maximumPrimaryColumnWidth = 450
            navigationController.splitViewController?.preferredDisplayMode = .oneBesideSecondary
            navigationController.splitViewController?.preferredSplitBehavior = .tile
        }
    }
}

extension View {
    func slNavigationView() -> some View {
        modifier(SLNavigationViewModifier())
    }
}
