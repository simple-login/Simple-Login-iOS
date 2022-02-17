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
    @State private var showingAliasEmailSheet = false
    @State private var showingAliasEmailFullScreen = false
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void
    let onToggle: () -> Void
    let onPin: () -> Void
    let onUnpin: () -> Void
    let onDelete: () -> Void

    init(alias: Alias,
         onCopy: @escaping () -> Void,
         onSendMail: @escaping () -> Void,
         onToggle: @escaping () -> Void,
         onPin: @escaping () -> Void,
         onUnpin: @escaping () -> Void,
         onDelete: @escaping () -> Void) {
        self.alias = alias
        self.onCopy = onCopy
        self.onSendMail = onSendMail
        self.onToggle = onToggle
        self.onPin = onPin
        self.onUnpin = onUnpin
        self.onDelete = onDelete
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
        .fullScreenCover(isPresented: $showingAliasEmailFullScreen) {
            AliasEmailView(email: alias.email)
        }
        .sheet(isPresented: $showingAliasEmailSheet) {
            AliasEmailView(email: alias.email)
        }
        .contextMenu {
            Section {
                Button(action: {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        showingAliasEmailSheet = true
                    } else {
                        showingAliasEmailFullScreen = true
                    }
                }, label: {
                    Label.enterFullScreen
                })
            }

            Section {
                if alias.pinned {
                    Button(action: onPin) {
                        Label.unpin
                    }
                } else {
                    Button(action: onUnpin) {
                        Label.pin
                    }
                }
            }

            Section {
                DeleteMenuButton(action: onDelete)
            }
        }
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
                Label.copy
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onSendMail()
            } label: {
                Label.sendEmail
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onToggle()
            } label: {
                Label("Active", systemImage: alias.enabled ? "checkmark.circle.fill" : "circle.dashed")
                    .foregroundColor(alias.enabled ? .accentColor : Color(.darkGray))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .font(.subheadline)
        .foregroundColor(.accentColor)
    }
}

struct AliasCompactView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AliasCompactView(alias: .ccohen,
                             onCopy: {},
                             onSendMail: {},
                             onToggle: {},
                             onPin: {},
                             onUnpin: {},
                             onDelete: {})
            AliasCompactView(alias: .claypool,
                             onCopy: {},
                             onSendMail: {},
                             onToggle: {},
                             onPin: {},
                             onUnpin: {},
                             onDelete: {})
        }
        .accentColor(.slPurple)
    }
}
