//
//  LogInWithProtonButtonView.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 27/07/2022.
//

import SwiftUI

struct LogInWithProtonButtonView: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    Image("Proton")
                    Spacer()
                }
                Text("Log in with Proton")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.proton)
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.proton)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.proton, lineWidth: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LogInWithProtonButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LogInWithProtonButtonView {}
            .padding()
    }
}
