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
            case .signUp: return "Create account"
            }
        }
    }
}

struct EmailPasswordView: View {
    @State private var showingClearEmailButton = false
    @State private var showingClearPasswordButton = false
    @State private var showingPassword = false
    @State private var invalidEmail = false
    @State private var invalidPassword = false
    @Binding var email: String
    @Binding var password: String
    let mode: Mode
    let onAction: () async -> Void

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                ZStack(alignment: .trailing) {
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.accentColor)
                            TextField("Email", text: $email) { changed in
                                withAnimation {
                                    showingClearEmailButton = changed
                                    invalidEmail = false
                                }
                            }
                            .textContentType(.username)
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

                    if showingClearEmailButton {
                        Button(action: {
                            email = ""
                        }, label: {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(Color.gray)
                        })
                    }
                }

                Color.gray.opacity(0.2)
                    .frame(height: 1)
                    .padding(.horizontal, -16)

                ZStack(alignment: .trailing) {
                    VStack {
                        HStack {
                            Image(systemName: "lock.circle")
                                .foregroundColor(.accentColor)
                            if showingPassword {
                                TextField("Password", text: $password) { changed in
                                    withAnimation {
                                        showingClearPasswordButton = changed
                                        invalidPassword = false
                                    }
                                }
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.trailing, 30)
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(.trailing, 30)
                                    .onTapGesture {
                                        withAnimation {
                                            showingClearPasswordButton = true
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

                    if showingClearPasswordButton {
                        Button(action: {
                            showingPassword.toggle()
                        }, label: {
                            Image(systemName: showingPassword ? "eye.slash" : "eye")
                                .foregroundColor(Color.gray)
                        })
                    }
                }
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            PrimaryButton(title: mode.title) {
                switch mode {
                case .logIn:
                    await onAction()
                case .signUp:
                    withAnimation {
                        invalidEmail = !email.isValidEmail
                        invalidPassword = password.count < 8
                    }
                    if !invalidEmail && !invalidPassword {
                        await onAction()
                    }
                }
            }
            .padding(.vertical, 4)
            .opacity((email.isEmpty || password.isEmpty) ? 0.5 : 1)
            .disabled(email.isEmpty || password.isEmpty)
        }
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.minLength * 3 / 5 : .infinity)
    }
}

/*
struct EmailPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EmailPasswordView(email: .constant(""),
                          password: .constant(""),
                          mode: .logIn) {}
                          .padding()
    }
}
*/
