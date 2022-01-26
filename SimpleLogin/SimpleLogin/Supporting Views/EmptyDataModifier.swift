//
//  EmptyDataModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 09/12/2021.
//

import SwiftUI

struct EmptyDataModifier: ViewModifier {
    let isEmpty: Bool
    let placeholder: AnyView

    func body(content: Content) -> some View {
        if isEmpty {
            placeholder
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func emptyPlaceholder<PlaceholderView: View>(isEmpty: Bool,
                                                 placeholder: @escaping () -> PlaceholderView) -> some View {
        modifier(EmptyDataModifier(isEmpty: isEmpty, placeholder: AnyView(placeholder())))
    }
}
