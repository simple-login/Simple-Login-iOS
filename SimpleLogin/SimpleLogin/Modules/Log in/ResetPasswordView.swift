//
//  ResetPasswordView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 22/09/2021.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var email = ""
    let onReset: (String) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("")) {
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    Button(action: {
                        onReset(email)
                    }, label: {
                        Text("Reset password")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reset forgotten password", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Close")
            }))
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView { _ in }
    }
}
