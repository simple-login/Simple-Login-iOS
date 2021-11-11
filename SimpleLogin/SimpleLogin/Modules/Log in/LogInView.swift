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
    @Environment(\.loadingMode) private var loadingMode
    @Environment(\.toastMessage) private var toastMessage
    @StateObject private var viewModel: LogInViewModel

    @AppStorage("Email") private var email = ""
    @State private var password = ""

    @State private var showingOptionActionSheet = false
    @State private var showingAboutView = false
    @State private var showingApiKeyView = false
    @State private var showingApiUrlView = false
    @State private var showingResetPasswordView = false

    @State private var launching = true
    @State private var showingSignUpView = false

    @State private var mfaKey = ""
    @State private var showOtpView = false

    let onComplete: (ApiKey, SLClient) -> Void

    init(apiUrl: String, onComplete: @escaping (ApiKey, SLClient) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(apiUrl: apiUrl))
        self.onComplete = onComplete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // A vary pale color to make background tappable
                Color.gray.opacity(0.01)

                VStack {
                    if !launching {
                        topView
                    }

                    Spacer()

                    Image("LogoWithName")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width / 3, 150))

                    if !launching {
                        EmailPasswordView(email: $email, password: $password) {
                            viewModel.logIn(email: email, password: password, device: UIDevice.current.name)
                        }
                        .padding()
                        .fullScreenCover(isPresented: $showOtpView) {
                            OtpView(mfaKey: mfaKey,
                                    // swiftlint:disable:next force_unwrapping
                                    client: viewModel.client!) { apiKey in
                                showOtpView = false
                                // swiftlint:disable:next force_unwrapping
                                onComplete(apiKey, viewModel.client!)
                            }
                            .loadableToastable()
                        }
                    } else {
                        ProgressView()
                    }

                    Spacer()

                    if !launching {
                        bottomView
                            .fixedSize(horizontal: false, vertical: true)
                            .fullScreenCover(isPresented: $showingSignUpView, content: SignUpView.init)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
        .onReceive(Just(preferences.apiUrl)) { apiUrl in
            viewModel.updateApiUrl(apiUrl)
        }
        .onReceive(Just(viewModel.error)) { error in
            if let error = error {
                toastMessage.wrappedValue = error
                viewModel.handledError()
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            if isLoading {
                loadingMode.wrappedValue.startLoading()
            } else {
                loadingMode.wrappedValue.stopLoading()
            }
        }
        .onReceive(Just(viewModel.userLogin)) { userLogin in
            if let userLogin = userLogin,
               userLogin.isMfaEnabled {
                showOtpView = true
                mfaKey = viewModel.userLogin?.mfaKey ?? ""
                viewModel.handledUserLogin()
            }
        }
        .onAppear {
            if let apiKey = KeychainService.shared.getApiKey(),
               let client = viewModel.client {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete(apiKey, client)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        launching = false
                    }
                }
            }
        }
    }

    private var optionActionSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = []
        buttons.append(ActionSheet.Button.default(Text("About SimpleLogin")) {
            showingAboutView = true
        })

        buttons.append(ActionSheet.Button.default(Text("Log in using API key")) {
            showingApiKeyView = true
        })

        buttons.append(ActionSheet.Button.default(Text("Edit API URL")) {
            showingApiUrlView = true
        })

        buttons.append(ActionSheet.Button.default(Text("Reset forgotten password")) {
            showingResetPasswordView = true
        })

        buttons.append(.cancel())

        return ActionSheet(title: Text("SimpleLogin"), buttons: buttons)
    }

    private var topView: some View {
        HStack {
            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingAboutView) {
                    AboutView()
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiKeyView) {
                    ApiKeyView { apiKey in
                        if let client = viewModel.client {
                            onComplete(apiKey, client)
                        } else {
                            toastMessage.wrappedValue = "Invalid API URL"
                        }
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
                    ResetPasswordView { email in
                        // TODO: Reset password
                    }
                }

            Spacer()

            Button(action: {
                showingOptionActionSheet = true
            }, label: {
                if #available(iOS 15, *) {
                    Image(systemName: "list.bullet.circle.fill")
                } else {
                    Image(systemName: "list.bullet")
                }
            })
                .font(.title2)
        }
        .padding()
        .actionSheet(isPresented: $showingOptionActionSheet) {
            optionActionSheet
        }
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
}
