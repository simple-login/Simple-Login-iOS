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

/// Segments work well at standard sizes; menus keep long options readable with Dynamic Type.
private struct AdaptivePickerStyle: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ViewBuilder
    func body(content: Content) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            content.pickerStyle(.menu)
        } else {
            content.pickerStyle(.segmented)
        }
    }
}

extension View {
    func adaptivePickerStyle() -> some View {
        modifier(AdaptivePickerStyle())
    }
}
