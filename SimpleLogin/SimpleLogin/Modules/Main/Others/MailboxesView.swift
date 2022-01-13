//
//  MailboxesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct MailboxesView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = MailboxesViewModel()
    @State private var showingLoadingAlert = false
    @State private var selectedMailbox: Mailbox?
    @State private var mailboxToBeDeleted: Mailbox?

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
        .onAppear {
            viewModel.getMailboxes(session: session)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .actionSheet(isPresented: showingOptionsActionSheet) {
            optionsActionSheet
        }
        .alert(isPresented: showingDeletionAlert) {
            deletionAlert
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
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
                viewModel.makeDefault(mailbox: selectedMailbox,
                                      session: session)
            })
        }
        buttons.append(.destructive(Text("Delete")) {
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
            viewModel.delete(mailbox: mailboxToBeDeleted,
                             session: session)
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
                Text("Default")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.slPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
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
