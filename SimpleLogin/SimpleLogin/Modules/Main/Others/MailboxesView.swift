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

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        List {
            ForEach(viewModel.mailboxes, id: \.id) { mailbox in
                MailboxView(mailbox: mailbox)
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
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
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
