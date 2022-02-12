//
//  MailboxesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct MailboxesView: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @StateObject private var viewModel: MailboxesViewModel
    @State private var showingAddMailboxView = false
    @State private var showingLoadingAlert = false
    @State private var selectedMailbox: Mailbox?
    @State private var mailboxToBeDeleted: Mailbox?

    init(session: Session) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
    }

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingOptionsActionSheet = Binding<Bool>(get: {
            selectedMailbox != nil
        }, set: { isShowing in
            if !isShowing {
                selectedMailbox = nil
            }
        })

        let showingDeletionAlert = Binding<Bool>(get: {
            mailboxToBeDeleted != nil
        }, set: { isShowing in
            if !isShowing {
                mailboxToBeDeleted = nil
            }
        })

        List {
            ForEach(viewModel.mailboxes, id: \.id) { mailbox in
                MailboxView(mailbox: mailbox)
                    .onTapGesture {
                        if !mailbox.default {
                            selectedMailbox = mailbox
                        }
                    }
            }
            .navigationBarTitle("Mailboxes")
        }
        .listStyle(InsetGroupedListStyle())
        .introspectTableView { tableView in
            tableView.refreshControl = viewModel.refreshControl
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if hapticFeedbackEnabled {
                        Vibration.light.vibrate()
                    }
                    showingAddMailboxView = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .onAppear {
            viewModel.fetchMailboxes(refreshing: false)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .sheet(isPresented: $showingAddMailboxView) {
            AddMailboxView { newMailbox in
                viewModel.addMailbox(email: newMailbox)
            }
            .forceDarkModeIfApplicable()
        }
        .actionSheet(isPresented: showingOptionsActionSheet) {
            optionsActionSheet
        }
        .alert(isPresented: showingDeletionAlert) {
            deletionAlert
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
    }

    private var optionsActionSheet: ActionSheet {
        guard let selectedMailbox = selectedMailbox else {
            return .init(title: Text("selectedMailbox is nil"),
                         buttons: [.cancel()])
        }
        guard !selectedMailbox.default else {
            return .init(title: Text("No option for default mailbox"),
                         buttons: [.cancel()])
        }
        var buttons: [ActionSheet.Button] = []
        if selectedMailbox.verified {
            buttons.append(.default(Text("Set as default")) {
                viewModel.makeDefault(mailbox: selectedMailbox)
            })
        }
        buttons.append(.destructive(Text("Delete")) {
            if hapticFeedbackEnabled {
                Vibration.warning.vibrate(fallBackToOldSchool: true)
            }
            mailboxToBeDeleted = selectedMailbox
        })
        buttons.append(.cancel())
        return .init(title: Text("Mailbox"),
                     message: Text("\(selectedMailbox.email)"),
                     buttons: buttons)
    }

    private var deletionAlert: Alert {
        guard let mailboxToBeDeleted = mailboxToBeDeleted else {
            return .init(title: Text("mailboxToBeDeleted is nil"),
                         message: nil,
                         dismissButton: .cancel())
        }
        let deleteButton = Alert.Button.destructive(Text("Yes, delete this alias")) {
            viewModel.delete(mailbox: mailboxToBeDeleted)
        }
        return .init(title: Text("Delete \(mailboxToBeDeleted.email)?"),
                     message: Text("Aliases associated with this mailbox will also be deleted. This operation is irreversible. Please confirm."),
                     primaryButton: .cancel(),
                     secondaryButton: deleteButton)
    }
}

private struct MailboxView: View {
    let mailbox: Mailbox

    var body: some View {
        HStack {
            Image(systemName: mailbox.verified ? "checkmark.seal.fill" : "checkmark.seal")
                .resizable()
                .scaledToFit()
                .foregroundColor(mailbox.verified ? .green : .gray)
                .frame(width: 20, height: 20, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(mailbox.email)
                    .fontWeight(.semibold)
                Text("\(mailbox.relativeCreationDateString) • \(mailbox.aliasCount) alias(es)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if mailbox.default {
                LabelText(text: "Default")
            }

            if !mailbox.verified {
                Text("Unverified")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.red, lineWidth: 1))
            }
        }
        .contentShape(Rectangle())
    }
}

private struct AddMailboxView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var newMailbox = ""
    let onAddMailbox: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("A verification email will be sent to this email address")) {
                    let placeholder = "my.another.email@example.com"
                    if #available(iOS 15, *) {
                        AutoFocusTextField(placeholder: placeholder,
                                           text: $newMailbox)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    } else {
                        TextField(placeholder, text: $newMailbox)
                            .labelsHidden()
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                    }
                }
            }
            .navigationBarTitle("New mailboxes")
            .navigationBarItems(leading: cancelButton, trailing: addButton)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    private var addButton: some View {
        Button(action: {
            onAddMailbox(newMailbox)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Add")
        })
            .disabled(!newMailbox.isValidEmail)
    }
}

struct MailboxesView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MailboxView(mailbox: .defaultVerified)
            MailboxView(mailbox: .normalUnverified)
            MailboxView(mailbox: .normalVerified)
        }
        .listStyle(InsetGroupedListStyle())
    }
}
