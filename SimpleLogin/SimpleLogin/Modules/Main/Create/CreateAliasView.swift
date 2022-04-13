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

    private let onCreateAlias: (Alias) -> Void
    private let onCancel: (() -> Void)?
    private let onOpenMyAccount: (() -> Void)?
    private let url: URL?

    init(session: Session,
         url: URL?,
         onCreateAlias: @escaping (Alias) -> Void,
         onCancel: (() -> Void)?,
         onOpenMyAccount: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.url = url
        self.onCreateAlias = onCreateAlias
        self.onCancel = onCancel
        self.onOpenMyAccount = onOpenMyAccount
    }

    var body: some View {
        NavigationView {
            Group {
                if let options = viewModel.options,
                   let mailboxes = viewModel.mailboxes {
                    ContentView(viewModel: viewModel,
                                options: options,
                                mailboxes: mailboxes,
                                url: url)
                } else if !viewModel.isLoading {
                    Button(action: {
                        viewModel.fetchOptionsAndMailboxes()
                    }, label: {
                        Label("Retry", systemImage: "gobackward")
                    })
                }
            }
            .navigationBarTitle("Create an alias", displayMode: .inline)
            .navigationBarItems(leading: cancelButton)
        }
        .accentColor(.slPurple)
        .emptyPlaceholder(isEmpty: viewModel.options?.canCreate == false) {
            UpgradeNeededView(onOk: onCancel) {
                onOpenMyAccount?()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.fetchOptionsAndMailboxes()
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
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            onCancel?()
        }, label: {
            Text("Cancel")
        })
    }
}

private struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel: CreateAliasViewModel
    @State private var showingEditMailboxesView = false
    @State private var prefix = ""
    @State private var suffix = ""
    @State private var mailboxIds = [Int]()
    @State private var notes = ""
    let options: AliasOptions
    let mailboxes: [Mailbox]
    let url: URL?

    var body: some View {
        Form {
            Section(footer: Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")) {
                prefixAndSuffixView
            }

            Section(header: Text("Mailboxes"),
                    footer: mailboxFooter) {
                mailboxesView
            }

            Section(header: Text("Notes"), footer: noteFooter) {
                TextEditor(text: $notes)
                    .frame(height: 80)
            }
        }
        .onAppear {
            suffix = options.suffixes.map { $0.value }.first ?? ""
            if let defaultMailbox = mailboxes.first(where: { $0.default }) ?? mailboxes.first {
                mailboxIds.append(defaultMailbox.id)
            }
            prefix = url?.notWwwHostname() ?? ""
            notes = url?.host ?? ""
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
                .transaction { transaction in
                    transaction.animation = nil
                }

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

    private var noteFooter: some View {
        VStack {
            let createButtonDisabled = !prefix.isValidPrefix || mailboxIds.isEmpty
            PrimaryButton(title: "Create") {
                guard let suffixObject = options.suffixes.first(where: { $0.value == suffix }) else { return }
                let creationOptions = AliasCreationOptions(hostname: nil,
                                                           prefix: prefix,
                                                           suffix: suffixObject,
                                                           mailboxIds: mailboxIds,
                                                           note: notes.isEmpty ? nil : notes,
                                                           name: nil)
                viewModel.createAlias(options: creationOptions)
            }
            .padding(.vertical)
            .opacity(createButtonDisabled ? 0.5 : 1)
            .disabled(createButtonDisabled)

            if prefix.isEmpty && notes.isEmpty {
                GeometryReader { geometry in
                    HStack {
                        Spacer()

                        let lineWidth = geometry.size.width / 5
                        horizontalLine
                            .frame(width: lineWidth)

                        Text("OR")
                            .font(.caption2)
                            .fontWeight(.medium)

                        horizontalLine
                            .frame(width: lineWidth)

                        Spacer()
                    }
                }

                Group {
                    Button("Random by word") {
                        viewModel.random(mode: .word)
                    }
                    .padding(.vertical, 10)

                    Button("Random by UUID") {
                        viewModel.random(mode: .uuid)
                    }
                }
                .foregroundColor(.slPurple)
                .font(.body)
            }
        }
    }

    private var horizontalLine: some View {
        Color.secondary
            .opacity(0.5)
            .frame(height: 1)
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
