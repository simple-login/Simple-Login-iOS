//
//  ClearButtonModeModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 15/01/2022.
//

import Introspect
import SwiftUI
import UIKit

struct ClearButtonModeModifier: ViewModifier {
    let mode: UITextField.ViewMode

    func body(content: Content) -> some View {
        content
            .introspectTextField { textField in
                textField.clearButtonMode = mode
            }
    }
}
