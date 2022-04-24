//
//  UnverifiedLabel.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 24/04/2022.
//

import SwiftUI

struct BorderedText: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.red, lineWidth: 1))
    }
}

extension BorderedText {
    static var unverified: BorderedText {
        BorderedText(text: "Unverified", color: .red)
    }
}
