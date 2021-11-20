//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = CreateAliasViewModel()
    @State private var showingLoadingAlert = false
    @State private var prefix = ""
    @State private var suffix = ""
    @State private var mailboxIds = [Int]()
    @State private var notes = ""
    @State private var name = ""

    let onCreateAlias: (Alias) -> Void

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            Group {
                if let options = viewModel.options {
                    ContentView(prefix: $prefix,
                                suffix: $suffix,
                                mailboxIds: $mailboxIds,
                                notes: $notes,
                                name: $name,
                                options: options)
                } else if !viewModel.isLoading {
                    Button(action: {
                        viewModel.fetchOptions(session: session)
                    }, label: {
                        Label("Retry", systemImage: "gobackward")
                    })
                }
            }
            .navigationBarTitle("Create an alias", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: createButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            viewModel.fetchOptions(session: session)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdAlias)) { createdAlias in
            if let createdAlias = createdAlias {
                onCreateAlias(createdAlias)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onReceive(Just(viewModel.options)) { options in
            if let options = options {
                if !options.canCreate {
                    // TODO: Ask for premium subscription
                }
            }
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    private var createButton: some View {
        Button(action: {
            print("Create")
        }, label: {
            Text("Create")
        })
            .disabled(!prefix.isValidPrefix || mailboxIds.isEmpty)
    }
}

private struct ContentView: View {
    @Binding var prefix: String
    @Binding var suffix: String
    @Binding var mailboxIds: [Int]
    @Binding var notes: String
    @Binding var name: String
    let options: AliasOptions

    var body: some View {
        Form {
            Section(header: Text("Address"),
                    footer: Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")) {
                prefixAndSuffixView
            }

            Section(header: Text("Mailboxes"),
                    footer: Text("The mailboxes that receive emails sent to this alias")) {
                Text("abc@gmail.com")
            }

            Section(header: Text("Display name"),
                    footer: Text("Your display name when sending emails from this alias")) {
                TextField("(Optional) Ex: John Doe", text: $name)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
            }

            Section(header: Text("Notes"),
                    footer: Text("Something to remind you about the usage of this alias")) {
                TextField("(Optional) Ex: For online shopping", text: $notes)
            }
        }
        .onAppear {
            suffix = options.suffixes.map { $0.value }.first ?? ""
        }
    }

    private var prefixAndSuffixView: some View {
        HStack(spacing: 2) {
            TextField("custom_prefix", text: $prefix)
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(prefix.isValidPrefix ? .primary : .red)
                .frame(minWidth: 50)

            Picker(selection: $suffix, label: Text(suffix)) {
                let suffixValues = options.suffixes.map { $0.value }
                ForEach(suffixValues, id: \.self) { value in
                    Text(value)
                        .tag(value)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
