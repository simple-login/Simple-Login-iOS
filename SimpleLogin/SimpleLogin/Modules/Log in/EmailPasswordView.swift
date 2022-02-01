//
//  EmailPasswordView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import SwiftUI

extension EmailPasswordView {
    enum Mode {
        case logIn, signUp

        var title: String {
            switch self {
            case .logIn: return "Log in"
            case .signUp: return "Sign up"
            }
        }
    }
}

struct EmailPasswordView: View {
    @State private var showPassword = false
    @State private var invalidEmail = false
    @State private var invalidPassword = false
    @Binding var email: String
    @Binding var password: String
    let mode: Mode
    let onAction: () -> Void

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                ZStack(alignment: .trailing) {
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.accentColor)
                            TextField("Email", text: $email) { _ in
                                withAnimation {
                                    invalidEmail = false
                                }
                            }
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.trailing, 24)
                        }

                        if invalidEmail {
                            HStack {
                                Text("Invalid email address")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }

                    Button(action: {
                        email = ""
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color.gray)
                    })
                }

                Color.gray.opacity(0.2)
                    .frame(height: 1)
                    .padding(.horizontal, -16)

                ZStack(alignment: .trailing) {
                    VStack {
                        HStack {
                            Image(systemName: "lock.circle")
                                .foregroundColor(.accentColor)
                            if showPassword {
                                TextField("Password", text: $password) { _ in
                                    withAnimation {
                                        invalidPassword = false
                                    }
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.trailing, 30)
                            } else {
                                SecureField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(.trailing, 30)
                                    .onTapGesture {
                                        withAnimation {
                                            invalidPassword = false
                                        }
                                    }
                            }
                        }

                        if invalidPassword {
                            HStack {
                                Text("Password must have more than 8 characters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }

                    Button(action: {
                        showPassword.toggle()
                    }, label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(Color.gray)
                    })
                }
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            Button(action: {
                switch mode {
                case .logIn:
                    onAction()
                case .signUp:
                    withAnimation {
                        invalidEmail = !email.isValidEmail
                        invalidPassword = password.count < 8
                    }
                    if !invalidEmail && !invalidPassword {
                        onAction()
                    }
                }
            }, label: {
                Text(mode.title)
                    .font(.headline)
                    .fontWeight(.bold)
            })
            .padding(.vertical, 4)
            .disabled(email.isEmpty || password.isEmpty)
        }
    }
}

struct EmailPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EmailPasswordView(email: .constant(""),
                          password: .constant(""),
                          mode: .logIn) {}
    }
}
