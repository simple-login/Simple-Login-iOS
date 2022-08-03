//
//  AliasDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

// A view that takes an alias as binding to properly show the alias details
// or a placeholder view when the binding is nil.
// To achieve the "dismiss" feeling when the alias is deleted in iPad.
struct AliasDetailWrapperView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedAlias: Alias?
    private let session: Session
    var onUpdateAlias: (Alias) -> Void
    var onDeleteAlias: (Alias) -> Void

    init(selectedAlias: Binding<Alias?>,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping (Alias) -> Void) {
        self._selectedAlias = selectedAlias
        self.session = session
        self.onUpdateAlias = onUpdateAlias
        self.onDeleteAlias = onDeleteAlias
    }

    var body: some View {
        if let selectedAlias = selectedAlias {
            // swiftlint:disable:next trailing_closure
            AliasDetailView(
                alias: selectedAlias,
                session: session,
                onUpdateAlias: onUpdateAlias,
                onDeleteAlias: { deletedAlias in
                    onDeleteAlias(deletedAlias)
                    // Dismiss when in single view mode (iPhone)
                    presentationMode.wrappedValue.dismiss()
                    // Show placeholder view in master detail mode (iPad)
                    self.selectedAlias = nil
                })
        } else {
            DetailPlaceholderView.aliasDetails
        }
    }
}

struct AliasDetailView: View {
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var showingDeletionAlert = false
    @State private var showingAliasEmailSheet = false
    @State private var showingAliasFullScreen = false
    @State private var copiedText: String?
    var onUpdateAlias: (Alias) -> Void
    var onDeleteAlias: (Alias) -> Void

    init(alias: Alias,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping (Alias) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
        self.onUpdateAlias = onUpdateAlias
        self.onDeleteAlias = onDeleteAlias
    }

    var body: some View {
        Form {
            ActionsSection(viewModel: viewModel,
                           copiedText: $copiedText,
                           enterFullScreen: showAliasInFullScreen)
            NotesSection(viewModel: viewModel)
            MailboxesSection(viewModel: viewModel)
            NameSection(viewModel: viewModel)
            ActivitiesSection(viewModel: viewModel, copiedText: $copiedText)
            Section {
                Button(action: {
                    Vibration.warning.vibrate(fallBackToOldSchool: true)
                    showingDeletionAlert = true
                }, label: {
                    Text("Delete")
                        .foregroundColor(.red)
                })
            }
        }
        .introspectTableView { tableView in
            tableView.refreshControl = viewModel.refreshControl
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
                    .onTapGesture {
                        showAliasInFullScreen()
                    }
            }
        }
        .disabled(viewModel.isUpdating)
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating
        }
        .onReceive(Just(viewModel.isRefreshed)) { isRefreshed in
            if isRefreshed {
                onUpdateAlias(viewModel.alias)
                viewModel.handledIsRefreshedBoolean()
            }
        }
        .onReceive(Just(viewModel.isDeleted)) { isDeleted in
            if isDeleted {
                onDeleteAlias(viewModel.alias)
            }
        }
        .fullScreenCover(isPresented: $showingAliasFullScreen) {
            AliasEmailView(email: viewModel.alias.email)
        }
        .sheet(isPresented: $showingAliasEmailSheet) {
            AliasEmailView(email: viewModel.alias.email)
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastCopyMessage($copiedText)
        .alertToastError($viewModel.error)
        .alert(isPresented: $showingDeletionAlert) {
            Alert.deleteConfirmation(alias: viewModel.alias) {
                viewModel.delete()
            }
        }
    }

    private func showAliasInFullScreen() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            showingAliasEmailSheet = true
        } else {
            showingAliasFullScreen = true
        }
    }
}

// MARK: - Sections
private struct ActionsSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingContacts = false
    @ObservedObject var viewModel: AliasDetailViewModel
    @Binding var copiedText: String?
    var enterFullScreen: () -> Void

    private var alias: Alias { viewModel.alias }

    var body: some View {
        Section(content: {
            Button(action: enterFullScreen) {
                Text("Enter full screen")
            }
        }, header: {
            VStack(alignment: .leading) {
                Text("\(alias.creationDateString) (\(alias.relativeCreationDateString))")
                HStack {
                    pinUnpinButton
                    activateDeactivateButton
                    copyButton
                    sendEmailButton
                }
                .frame(maxWidth: .infinity)
            }
            .textCase(nil)
            .noHorizontalPadding()
        })
    }

    private func button(action: @escaping () -> Void,
                        image: Image,
                        text: Text) -> some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 6) {
                image
                    .font(.title3)
                text
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var pinUnpinButton: some View {
        button(
            action: {
                Vibration.soft.vibrate()
                viewModel.update(option: .pinned(!alias.pinned))
            },
            image: Image(systemName: viewModel.alias.pinned ? "bookmark.slash" : "bookmark.fill"),
            text: Text(viewModel.alias.pinned ? "unpin" : "pin")
        )
            .foregroundColor(alias.pinned ? .red : .slPurple)
    }

    private var activateDeactivateButton: some View {
        button(
            action: {
                Vibration.soft.vibrate()
                viewModel.toggle()
            },
            image: Image(systemName: alias.enabled ? "circle.dashed" : "checkmark.circle.fill"),
            text: Text(alias.enabled ? "deactivate" : "activate")
        )
            .foregroundColor(alias.enabled ? .red : .slPurple)
    }

    private var copyButton: some View {
        button(
            action: {
                Vibration.soft.vibrate()
                copiedText = alias.email
                UIPasteboard.general.string = alias.email
            },
            image: Image(systemName: "doc.on.doc.fill"),
            text: Text("copy")
        )
            .foregroundColor(.slPurple)
    }

    private var sendEmailButton: some View {
        NavigationLink(
            isActive: $showingContacts,
            destination: {
                AliasContactsView(alias: alias, session: viewModel.session)
            },
            label: {
                button(
                    action: {
                        showingContacts = true
                    },
                    image: Image(systemName: "paperplane.fill"),
                    text: Text("contacts")
                )
                    .foregroundColor(.slPurple)
            })
    }
}

private struct MailboxesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var selectedUrlString: String?

    var body: some View {
        Section(content: {
            NavigationLink(destination: {
                EditMailboxesView(viewModel: viewModel)
            }, label: {
                let allMailboxes = viewModel.alias.mailboxes.map { $0.email }.joined(separator: "\n")
                Text(allMailboxes)
                    .lineLimit(5)
            })
        }, header: {
            Text("Mailboxes")
        }, footer: {
            Button("What are mailboxes?") {
                selectedUrlString = "https://simplelogin.io/docs/mailbox/add-mailbox/"
            }
            .foregroundColor(.slPurple)
        })
            .betterSafariView(urlString: $selectedUrlString)
    }
}

private struct NameSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingEditView = false

    var body: some View {
        Section(content: {
            Text(viewModel.alias.name ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .sheet(isPresented: $showingEditView) {
                    EditDisplayNameView(viewModel: viewModel)
                }
                .onTapGesture {
                    showingEditView = true
                }
        }, header: {
            Text("Display name")
        }, footer: {
            Text("Your display name when sending emails from this alias")
        })
    }
}

private struct NotesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingEditView = false

    var body: some View {
        Section(content: {
            Text(viewModel.alias.note ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .sheet(isPresented: $showingEditView) {
                    EditNotesView(viewModel: viewModel)
                }
                .onTapGesture {
                    showingEditView = true
                }
        }, header: {
            Text("Notes")
        })
    }
}

private struct ActivitiesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @Binding var copiedText: String?

    var body: some View {
        Section(content: {
            if viewModel.alias.noActivities {
                Text("No activities")
                    .foregroundColor(.secondary)
                    .font(.body.italic())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(0..<min(5, viewModel.activities.count), id: \.self) { index in
                    let activity = viewModel.activities[index]
                    ActivityView(copiedText: $copiedText, activity: activity)
                        .padding(.vertical, 4)
                }

                if viewModel.activities.count > 5 {
                    NavigationLink(destination: {
                        AllActivitiesView(viewModel: viewModel)
                    }, label: {
                        Text("Show all activities")
                    })
                }
            }
        }, header: {
            VStack(alignment: .leading) {
                Text("Last 14 days activities")
                if !viewModel.activities.isEmpty {
                    HStack {
                        section(action: .forward,
                                count: viewModel.alias.forwardCount)
                        Divider()
                        section(action: .reply,
                                count: viewModel.alias.replyCount)
                        Divider()
                        section(action: .block,
                                count: viewModel.alias.blockCount)
                    }
                }
            }
        })
            .onAppear {
                viewModel.getMoreActivitiesIfNeed(currentActivity: nil)
            }
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack {
            Label {
                Text(action.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            } icon: {
                Image(systemName: action.iconSystemName)
            }
            .foregroundColor(action.color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                // swiftlint:disable:next empty_count
                .opacity(count == 0 ? 0.5 : 1)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ActivityView: View {
    @Binding var copiedText: String?
    let activity: AliasActivity

    var body: some View {
        Menu(content: {
            Section {
                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = activity.reverseAlias
                    UIPasteboard.general.string = activity.reverseAlias
                }, label: {
                    Label("Copy reverse-alias\n(with display name)", systemImage: "doc.on.doc")
                })

                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = activity.reverseAliasAddress
                    UIPasteboard.general.string = activity.reverseAliasAddress
                }, label: {
                    Label("Copy reverse-alias\n(without display name)", systemImage: "doc.on.doc")
                })
            }

            Section {
                Button(action: {
                    if let mailToUrl = URL(string: "mailto:\(activity.reverseAliasAddress)") {
                        UIApplication.shared.open(mailToUrl)
                    }
                }, label: {
                    Label("Open default email client", systemImage: "paperplane")
                })
            }
        }, label: {
            HStack {
                Image(systemName: activity.action.iconSystemName)
                    .foregroundColor(activity.action.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.action == .reply ? activity.to : activity.from)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text("\(activity.dateString) (\(activity.relativeDateString))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
        })
    }
}

private struct AllActivitiesView: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var copiedText: String?

    var body: some View {
        Form {
            Section(content: {
                ForEach(0..<viewModel.activities.count, id: \.self) { index in
                    let activity = viewModel.activities[index]
                    ActivityView(copiedText: $copiedText, activity: activity)
                        .padding(.vertical, 4)
                        .onAppear {
                            viewModel.getMoreActivitiesIfNeed(currentActivity: activity)
                        }
                }
            }, header: {
                Text("Last 14 days activities")
            })
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
            }
        }
        .alertToastCopyMessage($copiedText)
    }
}

// MARK: - Edit views
private struct EditMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var selectedIds: [Int] = []

    init(viewModel: AliasDetailViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
        _selectedIds = .init(initialValue: viewModel.alias.mailboxes.map { $0.id })
    }

    var body: some View {
        Form {
            Section(content: {
                ForEach(viewModel.mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                            .foregroundColor(mailbox.verified ? .primary : .secondary)
                        Spacer()
                        if selectedIds.contains(mailbox.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                        if !mailbox.verified {
                            BorderedText.unverified
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard mailbox.verified else { return }
                        if selectedIds.contains(mailbox.id) && selectedIds.count > 1 {
                            selectedIds.removeAll { $0 == mailbox.id }
                        } else if !selectedIds.contains(mailbox.id) {
                            selectedIds.append(mailbox.id)
                        }
                    }
                }
            }, header: {
                if !viewModel.mailboxes.isEmpty {
                    Text("Mailboxes")
                }
            }, footer: {
                if !viewModel.mailboxes.isEmpty {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .mailboxIds(selectedIds))
                    }
                    .padding(.vertical)
                }
            })
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
            }
        }
        .onAppear {
            if viewModel.mailboxes.isEmpty {
                viewModel.getMailboxes()
            }
        }
        .onReceive(Just(viewModel.isLoadingMailboxes)) { isLoadingMailboxes in
            showingLoadingAlert = isLoadingMailboxes || viewModel.isUpdating
        }
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating || viewModel.isLoadingMailboxes
        }
        .onReceive(Just(viewModel.isUpdated)) { isUpdated in
            if isUpdated {
                presentationMode.wrappedValue.dismiss()
                viewModel.handledIsUpdatedBoolean()
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.updatingError)
    }
}

private struct EditNotesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    AdaptiveTextEditor(text: $notes)
                        .disabled(viewModel.isUpdating)
                        .frame(minHeight: 150)
                }, header: {
                    Text("Notes")
                }, footer: {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .note(notes))
                    }
                    .padding(.vertical)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AliasNavigationTitleView(alias: viewModel.alias)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .accentColor(.slPurple)
        .onAppear {
            notes = viewModel.alias.note ?? ""
        }
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating
        }
        .onReceive(Just(viewModel.isUpdated)) { isUpdated in
            if isUpdated {
                presentationMode.wrappedValue.dismiss()
                viewModel.handledIsUpdatedBoolean()
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.updatingError)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}

private struct EditDisplayNameView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var displayName = ""

    init(viewModel: AliasDetailViewModel) {
        _viewModel = .init(initialValue: viewModel)
        _displayName = .init(initialValue: viewModel.alias.name ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    TextField("", text: $displayName)
                        .disabled(viewModel.isUpdating)
                }, header: {
                    Text("Display name")
                }, footer: {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .name(displayName))
                    }
                    .padding(.vertical)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AliasNavigationTitleView(alias: viewModel.alias)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .accentColor(.slPurple)
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating
        }
        .onReceive(Just(viewModel.isUpdated)) { isUpdated in
            if isUpdated {
                presentationMode.wrappedValue.dismiss()
                viewModel.handledIsUpdatedBoolean()
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.updatingError)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}
