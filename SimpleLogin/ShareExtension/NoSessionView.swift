//
//  NoSessionView.swift
//  ShareExtension
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
            // swiftlint:disable:next line_length
            Text("This Share Extension helps you create aliases on the fly without leaving your current context.\nPlease open SimpleLogin application and log in first in order to use this feature.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(Color(.darkGray))
                .padding(.horizontal)
        }
    }
}
