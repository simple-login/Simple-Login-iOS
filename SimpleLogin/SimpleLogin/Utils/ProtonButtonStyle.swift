//
//  ProtonButtonStyle.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 27/07/2022.
//

import SwiftUI

struct ProtonButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.proton.opacity(0.1) : Color.clear)
    }
}

extension ButtonStyle where Self == ProtonButtonStyle {
    static var proton: ProtonButtonStyle { .init() }
}
