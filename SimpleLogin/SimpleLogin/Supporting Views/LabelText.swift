//
//  LabelText.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 11/02/2022.
//

import SwiftUI

struct LabelText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.slPurple)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
