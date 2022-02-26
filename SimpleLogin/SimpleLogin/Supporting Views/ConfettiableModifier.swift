//
//  ConfettiableModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 16/01/2022.
//

import ConfettiSwiftUI
import SwiftUI

struct ConfettiableModifier: ViewModifier {
    @Binding var counter: Int

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                ConfettiCannon(counter: $counter,
                               num: 300,
                               rainHeight: UIScreen.main.bounds.height,
                               openingAngle: Angle(degrees: 0),
                               closingAngle: Angle(degrees: 360),
                               radius: UIScreen.main.bounds.width / 2)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
