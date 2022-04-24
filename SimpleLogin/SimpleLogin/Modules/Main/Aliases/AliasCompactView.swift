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

    var body: some View {
        VStack(spacing: 8) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)

            if displayMode != .compact {
                if let activity = alias.latestActivity {
                    Label(title: {
                        HStack {
                            Text(activity.contact.email)
                            Text("(\(activity.relativeDateString))")
                        }
                        .foregroundColor(.secondary)
                    }, icon: {
                        Image(systemName: activity.action.iconSystemName)
                            .foregroundColor(activity.action.color)
                    })
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Label("\(alias.creationDateString) (\(alias.relativeCreationDateString))",
                          systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if displayMode != .compact {
                Label(alias.mailboxesString, systemImage: "tray.full.fill")
                    .lineLimit(3)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !alias.noActivities && displayMode == .default {
                ActivitiesView(alias: alias)
                    .padding(.leading)
            }

            if let note = alias.note {
                Label(title: {
                    Text(note)
                        .lineLimit(2)
                }, icon: {
                    Image(systemName: "square.and.pencil")
                })
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ActionsView(alias: alias,
                        onCopy: onCopy,
                        onSendMail: onSendMail,
                        onToggle: onToggle)
        }
        .padding(8)
        .opacity(alias.enabled ? 1 : 0.5)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
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
                    Button(action: onUnpin) {
                        Label.unpin
                    }
                } else {
                    Button(action: onPin) {
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
