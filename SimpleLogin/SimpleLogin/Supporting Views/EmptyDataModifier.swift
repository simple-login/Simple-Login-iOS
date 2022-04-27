//
//  EmptyDataModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 09/12/2021.
//

import SwiftUI

struct EmptyDataModifier: ViewModifier {
    let isEmpty: Bool
    let useZStack: Bool
    let placeholder: AnyView

    func body(content: Content) -> some View {
        if useZStack {
            ZStack {
                content
                if isEmpty {
                    placeholder
                }
            }
        } else {
            if isEmpty {
                placeholder
            } else {
                content
            }
        }
    }
}

extension View {
    @ViewBuilder
    func emptyPlaceholder<PlaceholderView: View>(isEmpty: Bool,
                                                 useZStack: Bool = false,
                                                 placeholder: @escaping () -> PlaceholderView) -> some View {
        modifier(EmptyDataModifier(isEmpty: isEmpty,
                                   useZStack: useZStack,
                                   placeholder: AnyView(placeholder())))
    }
}
