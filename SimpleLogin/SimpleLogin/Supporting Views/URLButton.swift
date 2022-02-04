//
//  URLButton.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import SwiftUI

struct URLButton<Content: View>: View {
    @Environment(\.openURL) private var openURL
    let urlString: String
    let content: Content
    let foregroundColor: Color

    init(urlString: String, foregroundColor: Color = .primary, @ViewBuilder content: () -> Content) {
        self.urlString = urlString
        self.foregroundColor = foregroundColor
        self.content = content()
    }

    var body: some View {
        Button(action: {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        }, label: {
            content
        })
        .foregroundColor(foregroundColor)
    }
}
