//
//  DeleteAccountView.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 27/07/2022.
//

import Combine
import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: DeleteAccountViewModel
    @State private var showingLoadingAlert = false
    @State private var password = ""
    let onDeleteAccount: () -> Void

    init(session: Session,
         onDeleteAccount: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(session: session))
        self.onDeleteAccount = onDeleteAccount
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("⚠️ You're about to delete your account.\nPlease enter your password.")
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("Your password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .introspectTextField { textField in
                        textField.clearButtonMode = .always
                    }
                Button(action: {
                    viewModel.deleteAccount(password: password)
                }, label: {
                    Text("Delete my account")
                        .foregroundColor(.red)
                })
                .disabled(password.isEmpty)
                .opacity(password.isEmpty ? 0.5 : 1)
                Spacer()
            }
            .navigationTitle("Entering sudo mode")
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .disabled(viewModel.isLoading)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
        .alert(isPresented: $viewModel.accountDeleted) {
            Alert(title: Text("Your SimpleLogin account has been deleted successfully"),
                  message: Text("Thank you for having used SimpleLogin"),
                  dismissButton: .default(Text("Close"),
                                          action: onDeleteAccount))
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(session: .preview) {}
    }
}
