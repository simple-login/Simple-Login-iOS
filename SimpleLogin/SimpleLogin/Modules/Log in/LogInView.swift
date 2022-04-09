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

    @AppStorage("Email") private var email = ""
    @State private var password = ""

    @State private var showingAboutView = false
    @State private var showingApiKeyView = false
    @State private var showingApiUrlView = false
    @State private var showingResetPasswordView = false

    @State private var launching = true
    @State private var showingSignUpView = false

    @State private var otpMode: OtpMode?

    @State private var showingLoadingAlert = false

    @State private var isInEditingMode = false

    private let keyboardWillShowNotification = NotificationCenter.default
        .publisher(for: UIApplication.keyboardWillShowNotification, object: nil)

    private let keyboardWillHideNotification = NotificationCenter.default
        .publisher(for: UIApplication.keyboardWillHideNotification, object: nil)

    let onComplete: (ApiKey, SLClient) -> Void

    init(apiUrl: String, onComplete: @escaping (ApiKey, SLClient) -> Void) {
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

        ZStack {
            // A vary pale color to make background tappable
            Color.gray.opacity(0.01)

            VStack {
                if !launching {
                    topView
                }

                Spacer()

                if !isInEditingMode || UIDevice.current.userInterfaceIdiom != .phone {
                    LogoView()
                }

                if !launching {
                    EmailPasswordView(email: $email,
                                      password: $password,
                                      mode: .logIn) {
                        viewModel.logIn(email: email, password: password, device: UIDevice.current.name)
                    }
                    .padding()
                    .sheet(isPresented: showingOtpViewSheet) { otpView() }
                    .fullScreenCover(isPresented: showingOtpViewFullScreen) { otpView() }

                    if !isInEditingMode {
                        Button(action: {
                            showingResetPasswordView = true
                        }, label: {
                            Text("Forgot password?")
                        })
                    }
                } else {
                    ProgressView()
                }

                Spacer()

                if !launching && !isInEditingMode {
                    bottomView
                        .fixedSize(horizontal: false, vertical: true)
                        .fullScreenCover(isPresented: $showingSignUpView) {
                            if let client = viewModel.client {
                                SignUpView(client: client) { emai, password in
                                    self.email = emai
                                    self.password = password
                                    self.viewModel.logIn(email: email,
                                                         password: password,
                                                         device: UIDevice.current.name)
                                }
                            }
                        }
                }
            }
        }
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
                onComplete(apiKey, viewModel.client)
            }
            viewModel.handledUserLogin()
        }
        .onReceive(Just(viewModel.shouldActivate)) { shouldActivate in
            if shouldActivate {
                otpMode = .activate(email: email)
                viewModel.handledShouldActivate()
            }
        }
        .onAppear {
            if let apiKey = KeychainService.shared.getApiKey() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete(apiKey, viewModel.client)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        launching = false
                    }
                }
            }
        }
        .onReceive(keyboardWillShowNotification) { _ in
            withAnimation {
                isInEditingMode = true
            }
        }
        .onReceive(keyboardWillHideNotification) { _ in
            withAnimation {
                isInEditingMode = false
            }
        }
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
                    ApiKeyView(client: viewModel.client) { apiKey in
                        onComplete(apiKey, viewModel.client)
                    }
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiUrlView) {
                    ApiUrlView(apiUrl: preferences.apiUrl)
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingResetPasswordView) {
                    ResetPasswordView(client: viewModel.client)
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
            client: viewModel.client,
            onVerification: { apiKey in
                onComplete(apiKey, viewModel.client)
            },
            onActivation: {
                viewModel.logIn(email: email,
                                password: password,
                                device: UIDevice.current.name)
            })
    }
}
