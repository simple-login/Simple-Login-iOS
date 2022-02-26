//
//  AliasContactsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct AliasContactsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @StateObject private var viewModel: AliasContactsViewModel
    @State private var showingLoadingAlert = false
    @State private var copiedText: String?
    @State private var newContactEmail = ""
    @State private var selectedUrlString: String?

    init(alias: Alias, session: Session) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
    }

    var body: some View {
        let showingCopyAlert = Binding<Bool>(get: {
            copiedText != nil
        }, set: { isShowing in
            if !isShowing {
                copiedText = nil
            }
        })

        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingCreatedContactAlert = Binding<Bool>(get: {
            viewModel.createdContact != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledCreatedContact()
            }
        })

        Form {
            Section(header: Text("Create new contact"),
                    footer: createContactSectionFooter) {
                HStack {
                    TextField("Contact email", text: $newContactEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                    Button("Create") {
                        viewModel.createContact(contactEmail: newContactEmail)
                    }
                    .foregroundColor(.slPurple)
                    .disabled(newContactEmail.isEmpty)
                }
                .buttonStyle(.plain)
            }

            Section {
                if let contacts = viewModel.contacts, !contacts.isEmpty {
                    ForEach(contacts, id: \.id) { contact in
                        ContactView(contact: contact)
                            .padding(.horizontal, 4)
                            .overlay(menu(for: contact))
                    }
                } else if !viewModel.isFetchingContacts {
                    Text("No contacts")
                        .foregroundColor(.secondary)
                        .font(.body.italic())
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if viewModel.isFetchingContacts {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .introspectTableView { tableView in
            tableView.refreshControl = viewModel.refreshControl
        }
        .navigationBarTitle(viewModel.alias.email, displayMode: .inline)
        .onAppear {
            viewModel.getMoreContactsIfNeed(currentContact: nil)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdContact)) { createdContact in
            if createdContact != nil {
                newContactEmail = ""
            }
        }
        .betterSafariView(urlString: $selectedUrlString)
        .alertToastCopyMessage(isPresenting: showingCopyAlert, message: copiedText)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastMessage(isPresenting: showingCreatedContactAlert, message: "Created new contact")
    }

    private func menu(for contact: Contact) -> some View {
        Menu(content: {
            Section {
                Text(contact.email)
            }

            Section {
                Button(action: {
                    if hapticFeedbackEnabled {
                        Vibration.soft.vibrate()
                    }
                    copiedText = contact.reverseAlias
                    UIPasteboard.general.string = contact.reverseAlias
                }, label: {
                    Label("Copy reverse-alias\n(with display name)", systemImage: "doc.on.doc")
                })

                Button(action: {
                    if hapticFeedbackEnabled {
                        Vibration.soft.vibrate()
                    }
                    copiedText = contact.reverseAliasAddress
                    UIPasteboard.general.string = contact.reverseAliasAddress
                }, label: {
                    Label("Copy reverse-alias\n(without display name)", systemImage: "doc.on.doc")
                })
            }

            Section {
                Button(action: {
                    if let mailToUrl = URL(string: "mailto:\(contact.reverseAliasAddress)") {
                        UIApplication.shared.open(mailToUrl)
                    }
                }, label: {
                    Label("Send email", systemImage: "paperplane")
                })
            }

            Section {
                if contact.blockForward {
                    Button(action: {
                        viewModel.toggleContact(contact)
                    }, label: {
                        Label("Unblock", systemImage: "hand.thumbsup")
                    })
                } else {
                    Button(action: {
                        viewModel.toggleContact(contact)
                    }, label: {
                        Label("Block", systemImage: "hand.raised")
                    })
                }
            }

            Section {
                DeleteMenuButton {
                    viewModel.deleteContact(contact)
                }
            }
        }, label: {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }

    private var createContactSectionFooter: some View {
        Button("How to send emails from my alias?") {
            selectedUrlString = "https://simplelogin.io/faq/"
        }
    }
}

private struct ContactView: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 0) {
            Color(contact.blockForward ? (.darkGray) : .slPurple)
                .frame(width: 4)

            VStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(contact.email)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: false)
                    Text("\(contact.creationDateString) (\(contact.relativeCreationDateString))")
                        .fixedSize(horizontal: false, vertical: false)
                }
            }
            .padding(8)

            Spacer()

            if contact.blockForward {
                Text("⛔")
                    .font(.title)
                    .padding(.trailing)
            }
        }
        .background(contact.blockForward ? Color(.darkGray).opacity(0.05) : Color.slPurple.opacity(0.05))
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
