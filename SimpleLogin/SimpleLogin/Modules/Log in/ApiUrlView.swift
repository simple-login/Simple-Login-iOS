//
//  ApiUrlView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import SwiftUI

let kDefaultApiUrlString = "https://app.simplelogin.io/"

struct ApiUrlView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var isEditing = false
    @State private var currentApiUrl: String
    let apiUrl: String

    init(apiUrl: String) {
        self.apiUrl = apiUrl
        self._currentApiUrl = .init(initialValue: apiUrl)
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current API URL"),
                        footer: warningView) {
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
                        currentApiUrl = apiUrl
                        save()
                    }, label: {
                        Text("Reset to default value")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("API URL", displayMode: .inline)
            .navigationBarItems(leading: closeOrCancelButton,
                                trailing: editOrDoneButton)
        }
    }

    private var defaultApiUrlView: some View {
        Text("The default value is ") +
            Text(kDefaultApiUrlString)
            .fontWeight(.bold)
    }

    private var warningView: some View {
        Group {
            Text("⚠️ ") +
            Text("DO NOT change API URL unless you are hosting SimpleLogin with your own server")
        }
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
            defer { isEditing.toggle() }
            if isEditing {
                save()
            }
        }, label: {
            Text(isEditing ? "Done" : "Edit")
        })
    }

    private func save() {

    }
}

struct ApiUrlView_Previews: PreviewProvider {
    static var previews: some View {
        ApiUrlView(apiUrl: "https://google.com")
    }
}
