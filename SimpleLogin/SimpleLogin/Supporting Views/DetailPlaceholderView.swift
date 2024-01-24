//
//  DetailPlaceholderView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 08/02/2022.
//

import SwiftUI

struct DetailPlaceholderView: View {
    let systemIconName: String
    var message: String?

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    Image(systemName: systemIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width / 3)
                        .foregroundColor(.secondary)
                        .opacity(0.05)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let message = message {
                Text(message)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

extension DetailPlaceholderView {
    static var aliasDetails: DetailPlaceholderView {
        DetailPlaceholderView(systemIconName: "at",
                              message: "Select an alias to see its details here")
    }
}
