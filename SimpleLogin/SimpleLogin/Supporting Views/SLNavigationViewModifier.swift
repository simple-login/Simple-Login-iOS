//
//  SLNavigationViewModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 06/02/2022.
//

import SwiftUI
import SwiftUIIntrospect

struct SLNavigationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.introspect(.navigationView(style: .columns), on: .iOS(.v15)) { navigationController in
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
