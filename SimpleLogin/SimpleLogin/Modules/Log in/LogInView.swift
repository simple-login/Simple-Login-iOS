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
    @State private var showAbout = false
    @State private var mode: LogInMode = .emailPassword
    @State private var isLoading = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // A vary pale color to make background tappable
                Color.gray.opacity(0.01)

                VStack {
                    if !isLoading {
                        aboutView
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
                        signUpView
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading.toggle()
                }
            }
        }
    }

    private var aboutView: some View {
        HStack {
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
        .padding(.trailing)
    }

    private var logInModeView: some View {
        Button(action: {
            withAnimation {
                mode = mode.oppositeMode()
            }
        }, label: {
            Label(mode.title, systemImage: mode.systemImageName)
                .font(.caption)
        })
    }

    private var signUpView: some View {
        HStack(spacing: 2) {
            Text("I don't have an account.")
            Button(action: {
                print("Create account")
            }, label: {
                Text("Sign up")
                    .fontWeight(.bold)
            })
        }
        .font(.callout)
        .padding(.bottom)
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
