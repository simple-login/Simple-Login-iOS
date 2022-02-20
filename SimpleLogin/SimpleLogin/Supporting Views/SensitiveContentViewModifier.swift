//
//  SensitiveContentViewModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 20/02/2022.
//

import SwiftUI

struct SensitiveContentViewModifier<PlaceholderContent: View>: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hidingContent = false
    let placeholderContent: () -> PlaceholderContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if hidingContent {
                placeholderContent()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            hidingContent = newPhase != .active
        }
    }
}

extension View {
    func sensitiveContent<V: View>(placeholderContent: @escaping () -> V) -> some View {
        modifier(SensitiveContentViewModifier(placeholderContent: placeholderContent))
    }
}
