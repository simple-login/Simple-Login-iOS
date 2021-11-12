//
//  ApiKeyView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct ApiKeyView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var viewModel = ApiKeyViewModel()
    @State private var value = ""
    let client: SLClient?
    let onSetApiKey: (ApiKey) -> Void

    var body: some View {
        let showingErrorToast = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { showing in
            if !showing {
                viewModel.handledError()
            }
        })
        NavigationView {
            Form {
                Section(header: Text(""),
                        footer: footerText) {
                    TextField("Enter API Key", text: $value)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }

                Section {
                    Button(action: {
                        viewModel.checkApiKey(apiKey: ApiKey(value: value))
                    }, label: {
                        Text("Set API Key")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                }
            }
            .navigationBarTitle("Log in using API key", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Close")
            }))
        }
        .accentColor(.slPurple)
        .onReceive(Just(viewModel.apiKey)) { apiKey in
            if let apiKey = apiKey {
                onSetApiKey(apiKey)
            }
        }
        .onAppear {
            viewModel.client = client
        }
        .toast(isPresenting: showingErrorToast) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: viewModel.error)
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
        ApiKeyView(client: nil) { _ in }
    }
}
