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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.contact.email)
                            Text(activity.relativeDateString)
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

            if !alias.noActivities, displayMode == .default {
                ActivitiesView(alias: alias)

            }

            if let note = alias.note, !note.isEmpty {
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let alias: Alias

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()),
                                 count: dynamicTypeSize.isAccessibilitySize ? 1 : 3), spacing: 8) {
            section(action: .forward, count: alias.forwardCount)
            section(action: .reply, count: alias.replyCount)
            section(action: .block, count: alias.blockCount)
        }
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(action.title).font(.caption).foregroundStyle(.secondary)
            Text(count, format: .number).font(.subheadline.weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(uiColor: .tertiarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

private struct ActionsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void
    let onToggle: () -> Void

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) { buttons }
            } else {
                HStack(spacing: 8) { buttons }
            }
        }
        .font(.subheadline)
        .buttonStyle(.borderless)
        .tint(.slPurple)
    }

    @ViewBuilder
    private var buttons: some View {
        Button(action: onCopy) {
            Label("Copy", systemImage: "doc.on.doc")
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Copy alias email")
        Button(action: onSendMail) {
            Label("Contacts", systemImage: "paperplane")
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        Button(action: onToggle) {
            Image(systemName: alias.enabled ? "checkmark.circle.fill" : "pause.circle")
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(alias.enabled ? "Deactivate alias" : "Activate alias")
        .accessibilityValue(alias.enabled ? "Active" : "Inactive")
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
