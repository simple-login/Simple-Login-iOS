//
//  OfflineLabelledViewModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/03/2022.
//

import SwiftUI

struct OfflineLabelledViewModifier: ViewModifier {
    @State private var noConnectionViewSize: CGSize = .zero
    @Binding var reachable: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .padding(.top, reachable ? 0 : noConnectionViewSize.height)
            if !reachable {
                Text("You're offline")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.red)
                    .bindSize($noConnectionViewSize)
            }
        }
    }
}

extension View {
    func offlineLabelled(reachable: Bool) -> some View {
        modifier(OfflineLabelledViewModifier(reachable: .constant(reachable)))
    }
}
