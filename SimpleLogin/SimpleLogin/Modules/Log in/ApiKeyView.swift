//
//  ApiKeyView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import SimpleLoginPackage
import SwiftUI

struct ApiKeyView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    let onSetApiKey: (ApiKey) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(""),
                        footer: footerText) {
                    TextField("API Key", text: $value)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }

                Section {
                    Button(action: {
                        onSetApiKey(ApiKey(value: value))
                    }, label: {
                        Text("Set API Key")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Log in using API key", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Close")
            }))
        }
    }

    private var footerText: some View {
        // swiftlint:disable:next line_length
        Text("⚠️ API Keys should be kept secret and treated like passwords, they can be used to gain access to your account.")
            .foregroundColor(.red)
    }
}

struct ApiKeyView_Previews: PreviewProvider {
    static var previews: some View {
        ApiKeyView { _ in }
    }
}
