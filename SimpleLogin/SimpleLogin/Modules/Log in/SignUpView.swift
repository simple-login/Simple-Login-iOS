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
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SignUpViewModel
    @State private var showingLoadingAlert = false
    @State private var showingRegisteredEmailAlert = false
    @State private var showingTermsAndConditions = false
    @State private var otpMode: OtpMode?
    let onSignUp: (String, String) -> Void

    init(apiService: APIServiceProtocol,
         onSignUp: @escaping (String, String) -> Void) {
        self._viewModel = StateObject(wrappedValue: .init(apiService: apiService))
        self.onSignUp = onSignUp
    }

    var body: some View {
        let showingOtpViewSheet = Binding<Bool>(get: {
            otpMode != nil && UIDevice.current.userInterfaceIdiom != .phone
        }, set: { isShowing in
            if !isShowing {
                otpMode = nil
            }
        })

        let showingOtpViewFullScreen = Binding<Bool>(get: {
            otpMode != nil && UIDevice.current.userInterfaceIdiom == .phone
        }, set: { isShowing in
            if !isShowing {
                otpMode = nil
            }
        })

        VStack(spacing: 0) {
            Spacer()

            if !viewModel.isShowingKeyboard {
                LogoView()
            }

            EmailPasswordView(email: $viewModel.email,
                              password: $viewModel.password,
                              mode: .signUp,
                              onAction: viewModel.register)
            .padding()

            Group {
                Text("By clicking \"Create account\", you agree to abide by SimpleLogin's Terms & Conditions.")
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
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

            if !viewModel.isShowingKeyboard {
                Divider()

                Button(action: dismiss.callAsFunction) {
                    Text("Already have an account")
                        .font(.callout)
                }
                .padding(.vertical)
            }
        }
        .contentShape(Rectangle())
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
                viewModel.handledRegisteredEmail()
            }
        }
        .fullScreenCover(isPresented: showingOtpViewFullScreen) { otpView }
        .sheet(isPresented: showingOtpViewSheet) { otpView }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
        .alert(isPresented: $showingRegisteredEmailAlert) {
            Alert(title: Text("You are all set"),
                  message: Text("We've sent an email to \(viewModel.email). Please check your inbox."),
                  dismissButton: .default(Text("OK")) {
                otpMode = .activate(email: viewModel.email)
            })
        }
    }

    private var otpView: some View {
        // swiftlint:disable trailing_closure
        OtpView(mode: $otpMode,
                apiService: viewModel.apiService,
                onActivation: {
            onSignUp(viewModel.email, viewModel.password)
            dismiss.callAsFunction()
        })
        // swiftlint:enable trailing_closure
    }
}
