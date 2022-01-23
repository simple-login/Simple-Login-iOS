//
//  AliasCompactView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 26/10/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasCompactView: View {
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void
    let onToggle: () -> Void

    init(alias: Alias,
         onCopy: @escaping () -> Void,
         onSendMail: @escaping () -> Void,
         onToggle: @escaping () -> Void) {
        self.alias = alias
        self.onCopy = onCopy
        self.onSendMail = onSendMail
        self.onToggle = onToggle
    }

    var body: some View {
        HStack(spacing: 0) {
            Color(alias.enabled ? .slPurple : (.darkGray))
                .frame(width: 4)

            VStack(spacing: 8) {
                EmailAndCreationDateView(alias: alias)
                if displayMode != .compact {
                    AliasMailboxesView(alias: alias)
                }
                if !alias.noActivities && displayMode == .default {
                    ActivitiesView(alias: alias)
                }
                ActionsView(alias: alias,
                            onCopy: onCopy,
                            onSendMail: onSendMail,
                            onToggle: onToggle)
                    .padding(.top, 8)
            }
            .padding(8)
        }
        .background(alias.enabled ? Color.slPurple.opacity(0.05) : Color(.darkGray).opacity(0.05))
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct EmailAndCreationDateView: View {
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default
    let alias: Alias

    var body: some View {
        HStack {
            Label {
                Text(alias.email)
                    .foregroundColor(alias.enabled ? .primary : .secondary)
            } icon: {
                if alias.pinned {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .font(.headline)

            Spacer()

            if displayMode != .compact {
                Group {
                    Text(alias.relativeCreationDateString)
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
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

private struct ActivitiesView: View {
    let alias: Alias

    var body: some View {
        HStack(spacing: 12) {
            section(action: .forward, count: alias.forwardCount)
            Divider()
            section(action: .reply, count: alias.replyCount)
            Divider()
            section(action: .block, count: alias.blockCount)
            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack {
            Text(action.title)
                .fontWeight(.semibold)
                .font(.caption2)
                .foregroundColor(action.color)

            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                // swiftlint:disable:next empty_count
                .opacity(count == 0 ? 0.5 : 1)

            Spacer()
        }
    }
}

private struct ActionsView: View {
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack {
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

            Spacer()

            Button {
                onToggle()
            } label: {
                Label("Active", systemImage: alias.enabled ? "checkmark.circle.fill" : "circle.dashed")
                    .foregroundColor(alias.enabled ? .accentColor : Color(.darkGray))
            }

            Spacer()
        }
        .font(.subheadline)
        .foregroundColor(.accentColor)
    }
}

struct AliasCompactView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AliasCompactView(alias: .ccohen, onCopy: {}, onSendMail: {}, onToggle: {})
            AliasCompactView(alias: .claypool, onCopy: {}, onSendMail: {}, onToggle: {})
        }
        .accentColor(.slPurple)
    }
}
