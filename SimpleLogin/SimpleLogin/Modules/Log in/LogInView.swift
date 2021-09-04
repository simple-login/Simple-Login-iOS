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
    @State private var apiKey = ""
    @State private var showApiUrl = false
    @State private var showAbout = false
    @State private var mode: LogInMode = .emailPassword
    @State private var isLaunching = true
    @State private var showSignUp = false
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
                    if !isLaunching {
                        topView
                    }

                    Spacer()

                    Image("LogoWithName")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width / 3, 150))

                    if !isLaunching {
                        switch mode {
                        case .emailPassword:
                            EmailPasswordView(viewModel: viewModel,
                                              email: $email,
                                              password: $password)
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
                        case .apiKey:
                            ApiKeyView(apiKey: $apiKey)
                                .padding()
                        }

                        logInModeView
                            .padding(.vertical)
                    } else {
                        ProgressView()
                    }

                    Spacer()

                    if !isLaunching {
                        bottomView
                            .fixedSize(horizontal: false, vertical: true)
                            .fullScreenCover(isPresented: $showSignUp, content: SignUpView.init)
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
                    isLaunching = false
                }
            }
        }
    }

    private var topView: some View {
        HStack {
            Button(action: {
                showApiUrl.toggle()
            }, label: {
                HStack {
                    Image(systemName: "link.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                    Text("API URL")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            })
            .fullScreenCover(isPresented: $showApiUrl) {
                ApiUrlView(apiUrl: preferences.apiUrl)
            }

            Spacer()

            Button(action: {
                showAbout.toggle()
            }, label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                    Text("About")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            })
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
        .padding(.horizontal)
    }

    private var logInModeView: some View {
        Button(action: {
            withAnimation {
                mode = mode.oppositeMode()
            }
        }, label: {
            Label(mode.title, systemImage: mode.systemImageName)
                .font(.callout)
        })
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
                showSignUp.toggle()
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

enum LogInMode {
    case emailPassword, apiKey

    func oppositeMode() -> LogInMode {
        switch self {
        case .emailPassword: return .apiKey
        case .apiKey: return .emailPassword
        }
    }

    var title: String {
        switch self {
        case .emailPassword: return "Log in using API key"
        case .apiKey: return "Log in using email & password"
        }
    }

    var systemImageName: String {
        switch self {
        case .emailPassword: return "arrow.forward.circle.fill"
        case .apiKey: return "arrow.backward.circle.fill"
        }
    }
}
