//
//  AliasContactsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import AlertToast
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
    @State private var selectedContact: Contact?
    @State private var copiedText: String?

    init(alias: Alias, session: Session) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
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
                            .onTapGesture {
                                selectedContact = contact
                            }
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
                            displayMode: viewModel.contacts?.isEmpty == false ? .large : .automatic)
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
        .actionSheet(isPresented: showingActionSheet) {
            actionsSheet
        }
        .sheet(isPresented: $showingCreateContactView) {
            CreateContactView(alias: viewModel.alias) {
                viewModel.refresh()
            }
            .forceDarkModeIfApplicable()
        }
        .toast(isPresenting: showingCopyAlert) {
            AlertToast(displayMode: .alert,
                       type: .systemImage("doc.on.doc", .secondary),
                       title: "Copied",
                       subTitle: copiedText)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(viewModel.error)
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
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
                if hapticFeedbackEnabled {
                    Vibration.soft.vibrate()
                }
                copiedText = selectedContact.reverseAlias
                UIPasteboard.general.string = selectedContact.reverseAlias
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Copy reverse-alias (w/o display name)")) {
                if hapticFeedbackEnabled {
                    Vibration.soft.vibrate()
                }
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
                viewModel.toggleContact(selectedContact)
            }
        )

        buttons.append(
            ActionSheet.Button.destructive(Text("Delete")) {
                viewModel.deleteContact(selectedContact)
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
