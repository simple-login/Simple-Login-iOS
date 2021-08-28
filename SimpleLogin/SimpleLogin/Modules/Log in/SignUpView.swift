//
//  SignUpView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var email = ""
    @State private var selectedTab = Tab.email

    enum Tab {
        case email, password
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.01)

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $selectedTab) {
                    EmailPageTabView(selectedTab: $selectedTab, email: $email)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .simultaneousGesture(DragGesture())
                        .tag(Tab.email)

                    PasswordPageTabView(selectedTab: $selectedTab, email: $email)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .simultaneousGesture(DragGesture())
                        .tag(Tab.password)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                Spacer()

                Divider()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Already have an account?")
                        .font(.caption)
                })
                .padding(.vertical)
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

struct EmailPageTabView: View {
    @State private var isEditing = false
    @Binding var selectedTab: SignUpView.Tab
    @Binding var email: String

    var body: some View {
        VStack {
            Text("The email address that you want to protect")
                .font(.callout)

            TextField("", text: $email) { editingChanged in
                isEditing = editingChanged
            }
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if email.isValidEmail && !isEditing {
                Button(action: {
                    selectedTab = .password
                }, label: {
                    Text("Continue")
                })
                .padding(.vertical, 20)
                .animation(.default)
            }

            if !email.isEmpty && !email.isValidEmail && !isEditing {
                Text("Email address is not valid")
                    .errorMessage()
            }
        }
        .padding(.horizontal)
    }
}

struct PasswordPageTabView: View {
    @State private var showPassword = false
    @State private var password = ""
    @State private var showPasswordError = false
    @Binding var selectedTab: SignUpView.Tab
    @Binding var email: String

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedTab = .email
                }, label: {
                    Image(systemName: "arrow.left.circle.fill")
                })

                Spacer()
            }

            Spacer()

            VStack(alignment: .center) {
                Text("Choose a password for")
                    .font(.callout)

                Text(email)
                    .font(.callout)
                    .fontWeight(.bold)
            }

            ZStack(alignment: .trailing) {
                if showPassword {
                    TextField("", text: $password)
                        .padding(.trailing, 30)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            withAnimation {
                                showPasswordError = false
                            }
                        }
                } else {
                    SecureField("", text: $password)
                        .padding(.trailing, 30)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            withAnimation {
                                showPasswordError = false
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
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            if showPasswordError {
                Text("Password must have more than 8 characters")
                    .errorMessage()
            }

            Button(action: {
                withAnimation {
                    showPasswordError = password.count < 8
                }
                if password.count >= 8 {
                    print("Sign up")
                }
            }, label: {
                Text("Sign up")
            })
            .padding(.vertical, 20)

            Spacer()
        }
        .padding(.horizontal)
    }
}
