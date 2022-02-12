//
//  SignUpView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import BetterSafariView
import Combine
import SimpleLoginPackage
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: SignUpViewModel
    @State private var showingLoadingAlert = false
    @State private var showingRegisteredEmailAlert = false
    @State private var showingTermsAndConditions = false
    @State private var email = ""
    @State private var password = ""

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

        ZStack {
            Color.gray.opacity(0.01)

            VStack(spacing: 0) {
                Spacer()

                LogoView()

                EmailPasswordView(email: $email, password: $password, mode: .signUp) {
                    viewModel.register(email: email, password: password)
                }
                .padding()

                Group {
                    Text("By clicking \"Create account\", you agree to abide by SimpleLogin's Terms & Conditions.")
                        .padding(.vertical)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        showingTermsAndConditions = true
                    }, label: {
                        Text("View Terms & Conditions")
                    })
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ?
                       UIScreen.main.minLength * 3 / 5 : .infinity)

                Spacer()

                Divider()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Already have an account")
                        .font(.callout)
                })
                .padding(.vertical)
            }
        }
        .safariView(isPresented: $showingTermsAndConditions) {
            // swiftlint:disable:next force_unwrapping
            SafariView(url: URL(string: "https://simplelogin.io/terms/")!)
        }
        .accentColor(.slPurple)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.registeredEmail)) { registeredEmail in
            if registeredEmail != nil {
                showingRegisteredEmailAlert = true
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorToast, error: viewModel.error)
        .alert(isPresented: $showingRegisteredEmailAlert) {
            Alert(title: Text("You are all set"),
                  message: Text("We've sent an email to \(viewModel.registeredEmail ?? ""). Please check your inbox."),
                  dismissButton: .default(Text("OK")) { presentationMode.wrappedValue.dismiss() })
        }
    }
}
