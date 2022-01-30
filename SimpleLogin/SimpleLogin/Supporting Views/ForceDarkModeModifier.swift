//
//  ForceDarkModeModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 16/01/2022.
//

import SwiftUI

let kForceDarkMode = "kForceDarkMode"

struct ForceDarkModeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(kForceDarkMode) private var forceDarkMode = false

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(forceDarkMode ? .dark : colorScheme)
    }
}

extension View {
    func forceDarkModeIfApplicable() -> some View {
        modifier(ForceDarkModeModifier())
    }
}
