//
//  AutoFocusTextField.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 10/11/2021.
//

import SwiftUI

@available(iOS 15, *)
struct AutoFocusTextField: View {
    @FocusState private var isFocused: Bool
    var placeholder: String?
    @Binding var text: String

    var body: some View {
        TextField(placeholder ?? "", text: $text)
            .labelsHidden()
            .disableAutocorrection(true)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    isFocused = true
                }
            }
    }
}

@available(iOS 15, *)
struct AutoFocusTextEditor: View {
    @FocusState private var isFocused: Bool
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .disableAutocorrection(true)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    isFocused = true
                }
            }
    }
}
