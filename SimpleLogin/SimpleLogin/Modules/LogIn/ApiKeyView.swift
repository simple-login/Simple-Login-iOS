//
//  ApiKeyView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import SwiftUI

struct ApiKeyView: View {
    @Binding var apiKey: String

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.accentColor)
                    TextField("API Key", text: $apiKey)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.trailing, 24)
                }

                Button(action: {
                    apiKey = ""
                }, label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.gray)
                })
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            Button(action: {
                print("Set api key")
            }, label: {
                Text("Set API Key")
                    .font(.headline)
                    .fontWeight(.bold)
            })
            .padding(.vertical, 4)
        }
    }
}

struct ApiKeyView_Previews: PreviewProvider {
    static var previews: some View {
        ApiKeyView(apiKey: .constant(""))
    }
}
