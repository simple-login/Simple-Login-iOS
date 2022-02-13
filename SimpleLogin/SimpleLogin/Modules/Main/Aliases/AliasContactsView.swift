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
    @State private var showingHelperText = false
    @State private var showingLoadingAlert = false
    @State private var showingCreateContactView = false
    @State private var copiedText: String?

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

        ScrollView {
            LazyVStack(spacing: 8) {
                if let contacts = viewModel.contacts {
                    ForEach(contacts, id: \.id) { contact in
                        ContactView(contact: contact)
                            .padding(.horizontal, 4)
                            .overlay(menu(for: contact))
                    }
                }

                if viewModel.isFetchingContacts {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }
        .introspectScrollView { scrollView in
            scrollView.refreshControl = viewModel.refreshControl
        }
        .navigationBarTitle(viewModel.contacts?.isEmpty == false ? viewModel.alias.email : "",
                            displayMode: viewModel.contacts?.isEmpty == false ? .large : .inline)
        .navigationBarItems(trailing: plusButton)
        .onAppear {
            viewModel.getMoreContactsIfNeed(currentContact: nil)
        }
        .emptyPlaceholder(isEmpty: viewModel.contacts?.isEmpty == true) {
            noContactView
                .navigationBarItems(trailing: plusButton)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .sheet(isPresented: $showingCreateContactView) {
            CreateContactView(alias: viewModel.alias) {
                viewModel.refresh()
            }
            .forceDarkModeIfApplicable()
        }
        .alertToastCopyMessage(isPresenting: showingCopyAlert, message: copiedText)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
    }

    var plusButton: some View {
        Button(action: {
            showingCreateContactView = true
        }, label: {
            Image(systemName: "plus")
        })
            .frame(minWidth: 24, minHeight: 24)
    }

    var noContactView: some View {
        ZStack(alignment: .topTrailing) {
            if showingHelperText {
                HStack {
                    Spacer()
                    Text("Add contact")
                    Image(systemName: "arrow.turn.right.up")
                }
                .padding(.trailing)
                .foregroundColor(.secondary)
            }

            DetailPlaceholderView(systemIconName: "at",
                                  message: viewModel.alias.email)
                .padding(.horizontal)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showingHelperText = true
                }
            }
        }
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
                let deleteAction: () -> Void = {
                    viewModel.deleteContact(contact)
                }
                let deleteLabel: () -> Label = {
                    Label("Delete", systemImage: "trash")
                }
                if #available(iOS 15.0, *) {
                    Button(role: .destructive, action: deleteAction, label: deleteLabel)
                } else {
                    Button(action: deleteAction, label: deleteLabel)
                }
            }
        }, label: {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
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
