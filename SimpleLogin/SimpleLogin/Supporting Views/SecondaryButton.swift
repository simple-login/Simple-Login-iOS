//
//  SecondaryButton.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.slPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.slPurple, lineWidth: 2)
                )
        }
    }
}
