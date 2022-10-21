//
//  PrimaryButton.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 20/02/2022.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () async -> Void

    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }, label: {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Color.slPurple)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
    }
}
