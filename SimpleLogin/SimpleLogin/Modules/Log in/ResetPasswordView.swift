//
//  ResetPasswordView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 22/09/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: ResetPasswordViewModel
    @State private var showingLoadingAlert = false
    @State private var email = ""

    init(client: SLClient) {
        _viewModel = StateObject(wrappedValue: .init(client: client))
    }

    var body: some View {
        let showingErrorToast = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { showing in
            if !showing {
                viewModel.handledError()
            }
        })

        let showingResetEmailAlert = Binding<Bool>(get: {
            viewModel.resetEmail != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledResetEmail()
            }
        })

        NavigationView {
            Form {
                Section(header: Text("Email address"),
                        footer: Text("Please make sure that you enter a correct email address or you won't be receiving our email.")) {
                    TextField("Your email address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    Button(action: {
                        viewModel.resetPassword(email: email)
                    }, label: {
                        Text("Reset password")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                        .disabled(!email.isValidEmail)
                }
            }
            .navigationBarTitle("Reset forgotten password", displayMode: .inline)
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
        .alert(isPresented: showingResetEmailAlert) {
            Alert(title: Text("We've sent you an email"),
                  message: Text("Please check the inbox of your email \(viewModel.resetEmail ?? "") and follow the instructions."),
                  dismissButton: .default(Text("OK"), action: { presentationMode.wrappedValue.dismiss() }))
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorToast) {
            AlertToast.errorAlert(viewModel.error)
        }
    }
}
