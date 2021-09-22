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

    @State private var showAboutView = false
    @State private var showApiKeyView = false
    @State private var showApiUrlView = false
    @State private var showResetPasswordView = false

    @State private var isLaunching = true
    @State private var showSignUpView = false

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

                    if !isLaunching {
                        bottomView
                            .fixedSize(horizontal: false, vertical: true)
                            .fullScreenCover(isPresented: $showSignUpView, content: SignUpView.init)
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
                        isLaunching = false
                    }
                }
            }
        }
    }

    private var topView: some View {
        let optionBinding = Binding<LogInOption>(
            get: {
                return .none
            },
            set: {
                switch $0 {
                case .about: showAboutView = true
                case .apiKey: showApiKeyView = true
                case .apiUrl: showApiUrlView = true
                case .resetPassword: showResetPasswordView = true
                default: break
                }
            }
        )
        let options: [LogInOption] = [.about, .apiKey, .apiUrl, .resetPassword]

        return HStack {
            EmptyView()
                .sheet(isPresented: $showAboutView) {
                    AboutView()
                }

            EmptyView()
                .sheet(isPresented: $showApiKeyView) {
                    ApiKeyView { apiKey in
                        if let client = viewModel.client {
                            onComplete(apiKey, client)
                        } else {
                            toastMessage.wrappedValue = "Invalid API URL"
                        }
                    }
                }

            EmptyView()
                .fullScreenCover(isPresented: $showApiUrlView) {
                    ApiUrlView(apiUrl: preferences.apiUrl)
                }

            EmptyView()
                .sheet(isPresented: $showResetPasswordView) {
                    ResetPasswordView { email in
                        // TODO: Reset password
                    }
                }

            Spacer()

            Picker(
                selection: optionBinding,
                label:
                    HStack(spacing: 4) {
                        Image(systemName: "ellipsis.circle.fill")
                        Text("More")
                    }) {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(option.title)
                        Image(systemName: option.systemImageName)
                    }
                    .tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
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
                showSignUpView.toggle()
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

private enum LogInOption: CaseIterable {
    case about, apiKey, apiUrl, resetPassword, none

    var title: String {
        switch self {
        case .about: return "About SimpleLogin"
        case .apiKey: return "Log in using API key"
        case .apiUrl: return "Edit API URL"
        case .resetPassword: return "Reset forgotten password"
        case .none: return ""
        }
    }

    var systemImageName: String {
        switch self {
        case .about: return "info.circle.fill"
        case .apiKey: return "arrow.forward.circle.fill"
        case .apiUrl: return "link.circle.fill"
        case .resetPassword: return "lock.circle.fill"
        case .none: return ""
        }
    }
}
