//
//  DeleteMenuButton.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 13/02/2022.
//

import SwiftUI

struct DeleteMenuButton: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    let action: () -> Void

    var body: some View {
        let label: () -> Label = { .delete }
        let hapticAction: () -> Void = {
            if hapticFeedbackEnabled {
                Vibration.warning.vibrate(fallBackToOldSchool: true)
            }
            action()
        }
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: hapticAction, label: label)
        } else {
            Button(action: hapticAction, label: label)
        }
    }
}
