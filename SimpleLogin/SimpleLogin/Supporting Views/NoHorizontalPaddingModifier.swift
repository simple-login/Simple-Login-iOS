//
//  NoHorizontalPaddingModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SwiftUI

struct NoHorizontalPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding(.horizontal, -20)
        } else {
            content
        }
    }
}

extension View {
    func noHorizontalPadding() -> some View {
        modifier(NoHorizontalPaddingModifier())
    }
}
