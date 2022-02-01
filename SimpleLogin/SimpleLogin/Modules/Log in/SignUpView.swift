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
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.gray.opacity(0.01)

            VStack(spacing: 0) {
                Spacer()

                Text("Create an account")
                    .font(.title)

                Spacer()
                    .frame(height: 40)
                    .padding(.horizontal)

                EmailPasswordView(email: $email, password: $password, mode: .signUp) {
                    print("Sign up")
                }
                .padding(.horizontal)

                Spacer()

                Divider()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Already have an account")
                        .font(.callout)
                })
                .padding(.vertical)
            }
        }
        .accentColor(.slPurple)
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
