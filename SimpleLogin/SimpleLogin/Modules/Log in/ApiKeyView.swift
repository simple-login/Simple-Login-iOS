//
//  ApiKeyView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct ApiKeyView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: ApiKeyViewModel
    @State private var showingLoadingAlert = false
    @State private var value = ""
    let onSetApiKey: (ApiKey) -> Void

    init(client: SLClient, onSetApiKey: @escaping (ApiKey) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(client: client))
        self.onSetApiKey = onSetApiKey
    }

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
                        .disabled(value.isEmpty)
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
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.apiKey)) { apiKey in
            if let apiKey = apiKey {
                onSetApiKey(apiKey)
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorToast, error: viewModel.error)
    }

    private var footerText: some View {
        // swiftlint:disable:next line_length
        Text("⚠️ API Keys should be kept secret and treated like passwords, they can be used to gain access to your account.")
            .foregroundColor(.red)
    }
}
