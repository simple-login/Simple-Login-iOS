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
    @StateObject private var viewModel: MailboxesViewModel
    @State private var showingAddMailboxAlert = false
    @State private var showingLoadingAlert = false
    @State private var mailboxToBeDeleted: Mailbox?

    init(session: Session) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
    }

    var body: some View {
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
                    .overlay(menu(for: mailbox))
            }
            .navigationBarTitle("Mailboxes")
        }
        .listStyle(InsetGroupedListStyle())
        .ignoresSafeArea(.keyboard)
        .introspectTableView { tableView in
            tableView.refreshControl = viewModel.refreshControl
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Vibration.light.vibrate()
                    showingAddMailboxAlert = true
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
        .alert(isPresented: showingDeletionAlert) {
            deletionAlert
        }
        .textFieldAlert(isPresented: $showingAddMailboxAlert,
                        config: addMailboxConfig)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private func menu(for mailbox: Mailbox) -> some View {
        Menu(content: {
            Section {
                Text(mailbox.email)
            }

            if !mailbox.default {
                if mailbox.verified {
                    Section {
                        Button(action: {
                            viewModel.makeDefault(mailbox: mailbox)
                        }, label: {
                            Text("Set as default")
                        })
                    }
                }

                Section {
                    DeleteMenuButton {
                        Vibration.warning.vibrate(fallBackToOldSchool: true)
                        mailboxToBeDeleted = mailbox
                    }
                }
            }
        }, label: {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }

    private var deletionAlert: Alert {
        guard let mailboxToBeDeleted = mailboxToBeDeleted else {
            return .init(title: Text("mailboxToBeDeleted is nil"),
                         message: nil,
                         dismissButton: .cancel())
        }
        let deleteButton = Alert.Button.destructive(Text("Yes, delete this mailbox")) {
            viewModel.delete(mailbox: mailboxToBeDeleted)
        }
        return .init(title: Text("Delete \(mailboxToBeDeleted.email)?"),
                     message: Text("Aliases associated with this mailbox will also be deleted. This operation is irreversible. Please confirm."),
                     primaryButton: .cancel(),
                     secondaryButton: deleteButton)
    }

    private var addMailboxConfig: TextFieldAlertConfig {
        TextFieldAlertConfig(title: "New mailbox",
                             message: "A verification email will be sent to this email address",
                             placeholder: "john.doe@example.com",
                             keyboardType: .emailAddress,
                             clearButtonMode: .never,
                             actionTitle: "Add") { newMailbox in
            if let newMailbox = newMailbox {
                viewModel.addMailbox(email: newMailbox)
            }
        }
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
