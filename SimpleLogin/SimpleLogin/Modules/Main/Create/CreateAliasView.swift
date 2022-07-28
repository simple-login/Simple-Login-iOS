//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CreateAliasViewModel
    @State private var showingLoadingAlert = false

    private let onCreateAlias: (Alias) -> Void
    private let onCancel: (() -> Void)?
    private let onOpenMyAccount: (() -> Void)?
    private let mode: Mode?

    enum Mode {
        case text(String)
        case url(URL)
    }

    init(session: Session,
         mode: Mode?,
         onCreateAlias: @escaping (Alias) -> Void,
         onCancel: (() -> Void)?,
         onOpenMyAccount: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.mode = mode
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
                                mode: mode)
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
            if viewModel.options == nil || viewModel.mailboxes == nil {
                viewModel.fetchOptionsAndMailboxes()
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdAlias)) { createdAlias in
            if let createdAlias = createdAlias {
                // Workaround of a strange bug: https://developer.apple.com/forums/thread/675216
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onCreateAlias(createdAlias)
                    presentationMode.wrappedValue.dismiss()
                }
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
    @ObservedObject var viewModel: CreateAliasViewModel
    @State private var isInitialized = false
    @State private var prefix = ""
    @State private var selectedSuffix: Suffix?
    @State private var mailboxIds = [Int]()
    @State private var notes = ""
    @State private var selectedUrlString: String?
    let options: AliasOptions
    let mailboxes: [Mailbox]
    let mode: CreateAliasView.Mode?

    var body: some View {
        Form {
            prefixAndSuffixSection
            notesSection
            mailboxesSection
            Section(content: {
                EmptyView()
            }, footer: {
                buttons
            })
        }
        .onAppear {
            guard !isInitialized else { return }
            isInitialized = true
            selectedSuffix = options.suffixes.first
            if let defaultMailbox = mailboxes.first(where: { $0.default }) ?? mailboxes.first {
                mailboxIds.append(defaultMailbox.id)
            }

            switch mode {
            case .url(let url):
                prefix = url.notWwwHostname() ?? ""
                notes = url.host ?? ""
            case .text(let text):
                notes = text
            case .none:
                break
            }
        }
    }

    private var prefixAndSuffixSection: some View {
        Section(content: {
            VStack(alignment: .leading) {
                TextField("Custom prefix", text: $prefix.animation())
                    .textFieldStyle(.roundedBorder)
                    .labelsHidden()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(prefix.isValidPrefix ? .primary : .red)
                    .introspectTextField { textField in
                        textField.clearButtonMode = .whileEditing
                    }

                if !prefix.isEmpty, !prefix.isValidPrefix {
                    Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .animation(.default, value: prefix)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let selectedSuffix = selectedSuffix {
                NavigationLink(destination: {
                    EditSuffixView(selectedSuffix: $selectedSuffix, suffixes: options.suffixes)
                }, label: {
                    VStack(alignment: .leading) {
                        Text(selectedSuffix.value)
                        Text(selectedSuffix.domainType.localizedDescription)
                            .font(.caption)
                            .foregroundColor(selectedSuffix.domainType.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                })
            }

            if prefix.isValidPrefix {
                VStack(alignment: .leading) {
                    Text("Complete alias address".uppercased())
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(prefix + (selectedSuffix?.value ?? ""))
                        .fontWeight(.medium)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }
        }, header: {
            Text("Alias address")
        })
    }

    private var notesSection: some View {
        Section(content: {
            TextEditor(text: $notes)
                .frame(height: 80)
        }, header: {
            Text("Notes")
        })
    }

    private var buttons: some View {
        VStack {
            let createButtonDisabled = !prefix.isValidPrefix || mailboxIds.isEmpty
            PrimaryButton(title: "Create") {
                guard let selectedSuffix = selectedSuffix else { return }
                let creationOptions = AliasCreationOptions(hostname: nil,
                                                           prefix: prefix,
                                                           suffix: selectedSuffix,
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

    private var mailboxesSection: some View {
        Section(content: {
            NavigationLink(destination: {
                EditMailboxesView(mailboxIds: $mailboxIds, mailboxes: mailboxes)
            }, label: {
                let selectedMailboxes = mailboxes.filter { mailboxIds.contains($0.id) }
                Text(selectedMailboxes.map { $0.email }.joined(separator: "\n"))
            })
        }, header: {
            Text("Mailboxes")
        }, footer: {
            Button("What are mailboxes?") {
                selectedUrlString = "https://simplelogin.io/docs/mailbox/add-mailbox/"
            }
            .foregroundColor(.slPurple)
        })
        .betterSafariView(urlString: $selectedUrlString)
    }

    private var horizontalLine: some View {
        Color.secondary
            .opacity(0.5)
            .frame(height: 1)
    }
}

private struct EditMailboxesView: View {
    @Binding var mailboxIds: [Int]
    let mailboxes: [Mailbox]

    var body: some View {
        Form {
            Section {
                ForEach(mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                            .foregroundColor(mailbox.verified ? .primary : .secondary)
                        Spacer()
                        if mailboxIds.contains(mailbox.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                        if !mailbox.verified {
                            BorderedText.unverified
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard mailbox.verified else { return }
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
        .navigationBarItems(trailing: reloadButton)
    }

    private var reloadButton: some View {
        Button(action: {
            if let defaultMailbox = mailboxes.first(where: { $0.default }) {
                mailboxIds = [defaultMailbox.id]
            }
        }, label: {
            Image(systemName: "gobackward")
        })
            .padding()
    }
}

struct EditSuffixView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedSuffix: Suffix?
    let suffixes: [Suffix]

    var body: some View {
        Form {
            ForEach(suffixes, id: \.value) { suffix in
                HStack {
                    VStack(alignment: .leading) {
                        Text(suffix.value)
                        Text(suffix.domainType.localizedDescription)
                            .font(.caption)
                            .foregroundColor(suffix.domainType.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    if suffix.value == selectedSuffix?.value {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSuffix = suffix
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
