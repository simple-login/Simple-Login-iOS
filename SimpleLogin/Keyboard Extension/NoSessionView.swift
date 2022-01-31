//
//  NoSessionView.swift
//  Keyboard Extension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import SwiftUI

struct NoSessionView: View {
    var body: some View {
        ZStack {
            Image("LogoWithName")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 2)
                .opacity(0.1)
                .padding()
            Text("Please open SimpleLogin application and log in. Then go to Settings ➝ General ➝ Keyboard ➝ Keyboards and give SimpleLogin keyboard full access.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(Color(.darkGray))
                .padding()
        }
        .background(Color(.systemGray6))
    }
}
