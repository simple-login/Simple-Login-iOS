//
//  AliasCompactView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 26/10/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasCompactView: View {
    @State private var enabled = false
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void

    var body: some View {
        HStack {
            Color(enabled ? .slPurple : (.darkGray))
                .frame(width: 4)

            VStack(spacing: 4) {
                EmailAndCreationDateView(enabled: $enabled, alias: alias)
                AliasMailboxesView(alias: alias)
                ActivityView(alias: alias)
                ActionsView(enabled: $enabled, onCopy: onCopy, onSendMail: onSendMail)
            }
            .padding(.vertical, 8)
        }
        .background(enabled ? Color.slPurple.opacity(0.05) : Color(.darkGray).opacity(0.05))
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct EmailAndCreationDateView: View {
    @Binding var enabled: Bool
    let alias: Alias

    var body: some View {
        HStack {
            Text(alias.email)
                .font(.headline)
                .foregroundColor(enabled ? .primary : .secondary)

            Spacer()

            Group {
                Text("3 days ago")
                Image(systemName: "chevron.right")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

private struct AliasMailboxesView: View {
    let alias: Alias

    var body: some View {
        HStack {
            Image(systemName: "tray.full.fill")
            Text(alias.mailboxesString)
                .lineLimit(2)
            Spacer()
        }
        .font(.caption)
        .foregroundColor(Color.secondary)
    }
}

private struct ActivityView: View {
    let alias: Alias

    var body: some View {
        HStack(spacing: 12) {
            // Forward
            section(title: "Forward",
                    titleColor: .green,
                    detail: "\(alias.forwardCount)")

            Divider()

            // Reply
            section(title: "Reply",
                    titleColor: .blue,
                    detail: "\(alias.replyCount)")

            Divider()

            // Block
            section(title: "Block",
                    titleColor: .red,
                    detail: "\(alias.blockCount)")

            if let latestActivity = alias.latestActivity {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Yesterday")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)

                    HStack(spacing: 2) {
                        Image(systemName: latestActivity.action.iconSystemName)
                            .foregroundColor(latestActivity.action.color)
                        Text(latestActivity.contact.email)
                        Spacer()
                    }
                    .font(.caption)

                    Spacer()
                }
            }

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func section(title: String, titleColor: Color, detail: String) -> some View {
        VStack {
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(titleColor)

            Text(detail)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()
        }
    }
}

private struct ActionsView: View {
    @Binding var enabled: Bool
    let onCopy: () -> Void
    let onSendMail: () -> Void

    var body: some View {
        HStack {
            Button {
                enabled.toggle()
            } label: {
                Label("Active", systemImage: enabled ? "checkmark.circle.fill" : "circle.dashed")
                    .foregroundColor(enabled ? .accentColor : Color(.darkGray))
            }

            Spacer()

            Button {
                onCopy()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

            Spacer()

            Button {
                onSendMail()
            } label: {
                Label("Send email", systemImage: "paperplane")
            }
        }
        .font(.subheadline)
        .foregroundColor(.accentColor)
        .padding(.horizontal)
    }
}

struct AliasCompactView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AliasCompactView(alias: .ccohen, onCopy: {}, onSendMail: {})
            AliasCompactView(alias: .claypool, onCopy: {}, onSendMail: {})
        }
        .accentColor(.slPurple)
    }
}
