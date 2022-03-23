//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CreateAliasViewModel
    @State private var showingLoadingAlert = false
    @State private var prefix = ""
    @State private var suffix = ""
    @State private var mailboxIds = [Int]()
    @State private var notes = ""

    private let onCreateAlias: (Alias) -> Void
    private let onCancel: (() -> Void)?
    private let url: URL?

    init(session: Session,
         url: URL?,
         onCreateAlias: @escaping (Alias) -> Void,
         onCancel: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.url = url
        self.onCreateAlias = onCreateAlias
        self.onCancel = onCancel
    }

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
                if let options = viewModel.options,
                   let mailboxes = viewModel.mailboxes {
                    ContentView(prefix: $prefix,
                                suffix: $suffix,
                                mailboxIds: $mailboxIds,
                                notes: $notes,
                                options: options,
                                mailboxes: mailboxes)
                } else if !viewModel.isLoading {
                    Button(action: {
                        viewModel.fetchOptionsAndMailboxes()
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
            viewModel.fetchOptionsAndMailboxes()
            self.prefix = url?.notWwwHostname() ?? ""
            self.notes = url?.host ?? ""
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
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            onCancel?()
        }, label: {
            Text("Cancel")
        })
    }

    private var createButton: some View {
        Button(action: {
            guard let options = viewModel.options,
                  let suffixObject = options.suffixes.first(where: { $0.value == suffix }) else { return }
            let creationOptions = AliasCreationOptions(hostname: nil,
                                                       prefix: prefix,
                                                       suffix: suffixObject,
                                                       mailboxIds: mailboxIds,
                                                       note: notes.isEmpty ? nil : notes,
                                                       name: nil)
            viewModel.createAlias(options: creationOptions)
        }, label: {
            Text("Create")
        })
            .disabled(!prefix.isValidPrefix || mailboxIds.isEmpty)
    }
}

private struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var showingEditMailboxesView = false
    @Binding var prefix: String
    @Binding var suffix: String
    @Binding var mailboxIds: [Int]
    @Binding var notes: String
    let options: AliasOptions
    let mailboxes: [Mailbox]

    var body: some View {
        Form {
            Section(header: Text("Address"),
                    footer: Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")) {
                prefixAndSuffixView
            }

            Section(header: Text("Mailboxes"),
                    footer: mailboxFooter) {
                mailboxesView
            }

            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 80)
            }
        }
        .onAppear {
            suffix = options.suffixes.map { $0.value }.first ?? ""
            if let defaultMailbox = mailboxes.first(where: { $0.default }) ?? mailboxes.first {
                mailboxIds.append(defaultMailbox.id)
            }
        }
        .sheet(isPresented: $showingEditMailboxesView) {
            EditMailboxesView(mailboxIds: $mailboxIds, mailboxes: mailboxes)
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

            Picker(
                selection: $suffix,
                content: {
                    let suffixValues = options.suffixes.map { $0.value }
                    ForEach(suffixValues, id: \.self) { value in
                        Text(value)
                            .tag(value)
                    }
                },
                label: {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Text(suffix)
                    } else {
                        EmptyView()
                    }
                })
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()

            Image(systemName: "chevron.down")
                .resizable()
                .scaledToFit()
                .font(.body.weight(.bold))
                .frame(width: 12)
                .foregroundColor(.slPurple)
        }
    }

    private var mailboxesView: some View {
        VStack {
            ForEach(mailboxIds, id: \.self) { id in
                if let mailbox = mailboxes.first { $0.id == id } {
                    HStack {
                        Text(mailbox.email)
                        Spacer()
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .onTapGesture {
            showingEditMailboxesView = true
        }
    }

    private var mailboxFooter: some View {
        Button("What are mailboxes?") {
            // swiftlint:disable:next force_unwrapping
            openURL(URL(string: "https://simplelogin.io/docs/mailbox/add-mailbox/")!)
        }
        .foregroundColor(.slPurple)
    }
}

private struct EditMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var mailboxIds: [Int]
    let mailboxes: [Mailbox]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(mailboxes, id: \.id) { mailbox in
                        HStack {
                            Text(mailbox.email)
                            Spacer()
                            if mailboxIds.contains(mailbox.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if mailboxIds.contains(mailbox.id) && mailboxIds.count > 1 {
                                mailboxIds.removeAll { $0 == mailbox.id }
                            } else if !mailboxIds.contains(mailbox.id) {
                                mailboxIds.append(mailbox.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mailboxes")
            .navigationBarItems(trailing: doneButton)
        }
        .accentColor(.slPurple)
        .navigationViewStyle(.stack)
    }

    private var doneButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        })
    }
}
