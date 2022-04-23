//
//  AliasEmailView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 23/04/2022.
//

import SwiftUI

/// Alias full screen
struct AliasEmailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var originalBrightness: CGFloat = 0.5
    @State private var percentage: Double = 0.5
    let email: String

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(verbatim: email)
                    .font(.system(size: (percentage + 1) * 24))
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Text("A")
                    Slider(value: $percentage)
                    Text("A")
                        .font(.title)
                }
            }
            .accentColor(.slPurple)
            .padding()
            .navigationBarItems(leading: closeButton)
            .onAppear {
                originalBrightness = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1.0)
            }
            .onDisappear {
                UIScreen.main.brightness = originalBrightness
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}
