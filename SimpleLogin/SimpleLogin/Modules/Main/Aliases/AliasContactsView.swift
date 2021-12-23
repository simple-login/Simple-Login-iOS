//
//  AliasContactsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import AlertToast
import SimpleLoginPackage
import SwiftUI

struct AliasContactsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel: AliasContactsViewModel
    @State private var showingHelperText = false
    @State private var selectedContact: Contact?
    @State private var copiedText: String?

    init(alias: Alias) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias))
    }

    var body: some View {
        let showingActionSheet = Binding<Bool>(get: {
            selectedContact != nil
        }, set: { isShowing in
            if !isShowing {
                selectedContact = nil
            }
        })

        let showingCopyAlert = Binding<Bool>(get: {
            copiedText != nil
        }, set: { isShowing in
            if !isShowing {
                copiedText = nil
            }
        })

        ScrollView {
            LazyVStack {
                if let contacts = viewModel.contacts {
                    ForEach(contacts, id: \.id) { contact in
                        ContactView(contact: contact)
                            .padding(.horizontal, 4)
                            .onTapGesture {
                                selectedContact = contact
                            }
                    }
                }

                if viewModel.isLoadingContacts {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }
        .navigationBarTitle(viewModel.contacts?.isEmpty == false ? viewModel.alias.email : "",
                            displayMode: viewModel.contacts?.isEmpty == false ? .large : .automatic)
        .navigationBarItems(trailing: plusButton)
        .onAppear {
            viewModel.getMoreContactsIfNeed(session: session,
                                            currentContact: nil)
        }
        .emptyPlaceholder(isEmpty: viewModel.contacts?.isEmpty == true) {
            noContactView
                .navigationBarItems(trailing: plusButton)
        }
        .actionSheet(isPresented: showingActionSheet) {
            actionsSheet
        }
        .toast(isPresenting: showingCopyAlert) {
            AlertToast(displayMode: .alert,
                       type: .systemImage("doc.on.doc", .secondary),
                       title: "Copied",
                       subTitle: copiedText)
        }
    }

    var plusButton: some View {
        Button(action: {
            print("add")
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
                .padding()
                .foregroundColor(.secondary)
            }

            ZStack {
                Image(systemName: "at")
                    .resizable()
                    .padding()
                    .scaledToFit()
                    .foregroundColor(.slPurple)
                    .opacity(0.03)
                Text(viewModel.alias.email)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showingHelperText = true
                }
            }
        }
    }

    private var actionsSheet: ActionSheet {
        guard let selectedContact = selectedContact else {
            return ActionSheet(title: Text("selectedContact is nil"))
        }

        var buttons: [ActionSheet.Button] = []

        buttons.append(
            ActionSheet.Button.default(Text("Copy reverse-alias (w/ display name)")) {
                copiedText = selectedContact.reverseAlias
                UIPasteboard.general.string = selectedContact.reverseAlias
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Copy reverse-alias (w/o display name)")) {
                copiedText = selectedContact.reverseAliasAddress
                UIPasteboard.general.string = selectedContact.reverseAliasAddress
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Compose email in default email client")) {
                if let mailToUrl = URL(string: "mailto:\(selectedContact.reverseAliasAddress)") {
                    UIApplication.shared.open(mailToUrl)
                }
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text(selectedContact.blockForward ? "Unblock" : "Block")) {
                viewModel.toggle(contact: selectedContact)
            }
        )

        buttons.append(
            ActionSheet.Button.destructive(Text("Delete")) {
                viewModel.delete(contact: selectedContact)
            }
        )

        buttons.append(.cancel())

        return ActionSheet(title: Text(selectedContact.email),
                           message: Text(selectedContact.reverseAlias),
                           buttons: buttons)
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
