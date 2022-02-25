//
//  ApiUrlView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import AlertToast
import SwiftUI

struct ApiUrlView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.presentationMode) private var presentationMode
    @State private var isEditing = false
    @State private var currentApiUrl: String
    @State private var showingInvalidApiUrlAlert = false
    let apiUrl: String

    init(apiUrl: String) {
        self.apiUrl = apiUrl
        self._currentApiUrl = .init(initialValue: apiUrl)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current API URL"),
                        footer: warningText) {
                    if isEditing {
                        TextField("", text: $currentApiUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.blue)
                    } else {
                        Text(currentApiUrl)
                    }
                }

                Section(footer: defaultApiUrlView) {
                    Button(action: {
                        currentApiUrl = kDefaultApiUrlString
                        save()
                    }, label: {
                        Text("Reset to default value")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                }
            }
            .navigationBarTitle("API URL", displayMode: .inline)
            .navigationBarItems(leading: closeOrCancelButton,
                                trailing: editOrDoneButton)
        }
        .accentColor(.slPurple)
        .alertToastError(isPresenting: $showingInvalidApiUrlAlert,
                         error: SLError.invalidApiUrl)
    }

    private var defaultApiUrlView: some View {
        Text("The default value is ") +
            Text(kDefaultApiUrlString)
            .fontWeight(.bold)
    }

    private var warningText: some View {
        Text("⚠️ Do not change API URL unless you are hosting SimpleLogin with your own server")
        .font(.footnote)
        .foregroundColor(.red)
    }

    private var closeOrCancelButton: some View {
        Button(action: {
            if isEditing {
                currentApiUrl = apiUrl
                isEditing = false
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }, label: {
            Text(isEditing ? "Cancel" : "Close")
        })
    }

    private var editOrDoneButton: some View {
        Button(action: {
            if isEditing {
                save()
            } else {
                isEditing = true
            }
        }, label: {
            Text(isEditing ? "Done" : "Edit")
        })
    }

    private func save() {
        guard URL(string: currentApiUrl) != nil else {
            showingInvalidApiUrlAlert = true
            return
        }
        isEditing = false
        preferences.apiUrl = currentApiUrl
    }
}

struct ApiUrlView_Previews: PreviewProvider {
    static var previews: some View {
        ApiUrlView(apiUrl: "https://google.com")
    }
}
