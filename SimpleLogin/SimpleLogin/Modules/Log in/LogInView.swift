//
//  LogInView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/07/2021.
//

import SwiftUI

struct LogInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var apiKey = ""
    @State private var showApiUrl = false
    @State private var showAbout = false
    @State private var mode: LogInMode = .emailPassword
    @State private var isLoading = true
    @State private var showSignUp = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // A vary pale color to make background tappable
                Color.gray.opacity(0.01)

                VStack {
                    if !isLoading {
                        topView
                    }

                    Spacer()

                    Image("LogoWithName")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width / 3, 150))

                    if !isLoading {
                        switch mode {
                        case .emailPassword:
                            EmailPasswordView(email: $email, password: $password)
                                .padding()
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

                    if !isLoading {
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isLoading.toggle()
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
                ApiUrlView(apiUrl: "https://app.simplelogin.io")
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

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
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
