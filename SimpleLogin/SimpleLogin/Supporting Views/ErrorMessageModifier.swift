//
//  ErrorMessageModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import SwiftUI

struct ErrorMessageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.red)
    }
}

extension View {
    func errorMessage() -> some View {
        modifier(ErrorMessageModifier())
    }
}
