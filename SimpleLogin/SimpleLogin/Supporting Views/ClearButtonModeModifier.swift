//
//  ClearButtonModeModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 15/01/2022.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

struct ClearButtonModeModifier: ViewModifier {
    let mode: UITextField.ViewMode

    func body(content: Content) -> some View {
        content
            .introspect(.textField, on: .iOS(.v15, .v16, .v17)) { textField in
                textField.clearButtonMode = mode
            }
    }
}
