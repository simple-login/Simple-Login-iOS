//
//  DeleteMenuButton.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 13/02/2022.
//

import SwiftUI

struct DeleteMenuButton: View {
    let action: () -> Void

    var body: some View {
        let label: () -> Label = { .delete }
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: action, label: label)
        } else {
            Button(action: action, label: label)
        }
    }
}
