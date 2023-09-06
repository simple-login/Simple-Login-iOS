//
//  LogInView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/07/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct LogInView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: LogInViewModel

    @State private var showingAboutView = false
    @State private var showingApiKeyView = false
    @State private var showingApiUrlView = false
    @State private var showingResetPasswordAlert = false
    @State private var showingResetEmailSentAlert = false

    @State private var launching = true
    @State private var showingSignUpView = false

    @State private var otpMode: OtpMode?

    @State private var showingLoadingAlert = false

    let onComplete: (ApiKey, APIServiceProtocol) -> Void

    init(apiUrl: String,
         onComplete: @escaping (ApiKey, APIServiceProtocol) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(apiUrl: apiUrl))
        self.onComplete = onComplete
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

        let showingResetEmailSentAlert = Binding<Bool>(get: {
            viewModel.resetEmail != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledResetEmail()
            }
        })

        VStack {
            if !launching {
                topView
            }

            Spacer()

            if !viewModel.isShowingKeyboard || UIDevice.current.userInterfaceIdiom != .phone {
                LogoView()
            }

            if !launching {
                VStack {
                    EmailPasswordView(email: $viewModel.email,
                                      password: $viewModel.password,
                                      mode: .logIn,
                                      onAction: viewModel.logIn)

                    Text("or")
                        .font(.caption)

                    LogInWithProtonButtonView(onSuccess: { apiKey in
                        onComplete(apiKey, viewModel.apiService)
                    }, onError: { error in
                        viewModel.error = error
                    })
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ?
                           UIScreen.main.minLength * 3 / 5 : .infinity)
                }
                .padding()
                .sheet(isPresented: showingOtpViewSheet) { otpView() }
                .fullScreenCover(isPresented: showingOtpViewFullScreen) { otpView() }

                if !viewModel.isShowingKeyboard {
                    Button(action: {
                        showingResetPasswordAlert = true
                    }, label: {
                        Text("Forgot password?")
                    })
                }
            } else {
                ProgressView()
            }

            Spacer()

            if !launching {
                bottomView
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(viewModel.isShowingKeyboard ? 0 : 1)
                    .fullScreenCover(isPresented: $showingSignUpView) {
                        SignUpView(apiService: viewModel.apiService) { email, password in
                            Task {
                                viewModel.email = email
                                viewModel.password = password
                                await viewModel.logIn()
                            }
                        }
                    }
            }
        }
        .contentShape(Rectangle())
        .animation(.default, value: viewModel.isShowingKeyboard)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onReceive(Just(preferences.apiUrl)) { apiUrl in
            viewModel.updateApiUrl(apiUrl)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.userLogin)) { userLogin in
            guard let userLogin = userLogin else { return }
            if userLogin.isMfaEnabled {
                otpMode = .logIn(mfaKey: userLogin.mfaKey ?? "")
            } else if let apiKey = userLogin.apiKey {
                onComplete(.init(value: apiKey), viewModel.apiService)
            }
            viewModel.handledUserLogin()
        }
        .onReceive(Just(viewModel.shouldActivate)) { shouldActivate in
            if shouldActivate {
                otpMode = .activate(email: viewModel.email)
                viewModel.handledShouldActivate()
            }
        }
        .onAppear {
            if let apiKey = KeychainService.shared.getApiKey() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete(apiKey, viewModel.apiService)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        launching = false
                    }
                }
            }
        }
        .alert(isPresented: showingResetEmailSentAlert) {
            Alert(title: Text("We've sent you an email"),
                  // swiftlint:disable:next line_length
                  message: Text("Please check the inbox of your email \(viewModel.resetEmail ?? "") and follow the instructions."),
                  dismissButton: .default(Text("OK")))
        }
        .textFieldAlert(isPresented: $showingResetPasswordAlert, config: resetPasswordConfig)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var topView: some View {
        HStack {
            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingAboutView) {
                    NavigationView {
                        AboutView()
                    }
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiKeyView) {
                    ApiKeyView(apiService: viewModel.apiService) { apiKey in
                        onComplete(apiKey, viewModel.apiService)
                    }
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiUrlView) {
                    ApiUrlView(apiUrl: preferences.apiUrl)
                }

            Spacer()

            Menu(content: {
                Section {
                    Button(action: {
                        showingApiKeyView = true
                    }, label: {
                        Label("Log in using API key", systemImage: "key")
                    })

                    Button(action: {
                        showingApiUrlView = true
                    }, label: {
                        Label("Edit API URL", systemImage: "link")
                    })
                }

                Section {
                    Button(action: {
                        showingAboutView = true
                    }, label: {
                        Label("About SimpleLogin", systemImage: "info.circle")
                    })
                }
            }, label: {
                if #available(iOS 15, *) {
                    Image(systemName: "list.bullet.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            })
        }
        .padding()
    }

    private var bottomView: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Spacer()

                    let lineWidth = geometry.size.width / 5
                    horizontalLine
                        .frame(width: lineWidth)

                    Text("OR")
                        .font(.caption2)
                        .fontWeight(.medium)

                    horizontalLine
                        .frame(width: lineWidth)

                    Spacer()
                }
            }

            Button(action: {
                showingSignUpView.toggle()
            }, label: {
                Text("Create new account")
                    .font(.callout)
            })
        }
        .padding(.bottom)
    }

    private var horizontalLine: some View {
        Color.secondary
            .opacity(0.5)
            .frame(height: 1)
    }

    private func otpView() -> some View {
        OtpView(
            mode: $otpMode,
            apiService: viewModel.apiService,
            onVerification: { apiKey in
                onComplete(apiKey, viewModel.apiService)
            },
            onActivation: viewModel.logIn)
    }

    private var resetPasswordConfig: TextFieldAlertConfig {
        TextFieldAlertConfig(title: "Reset forgotten password",
                             message: "Enter your email address",
                             placeholder: "Ex: john.doe@example.com",
                             keyboardType: .emailAddress,
                             autocapitalizationType: .none,
                             clearButtonMode: .whileEditing,
                             actionTitle: "Submit",
                             action: viewModel.resetPassword(email:))
    }
}
