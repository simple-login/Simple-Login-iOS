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

// swiftlint:disable file_length
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
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    if viewModel.alias.pinned {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.slPurple)
                    }
                    Text(viewModel.alias.email)
                        .fontWeight(.medium)
                }
                .opacity(viewModel.alias.enabled ? 1 : 0.5)
                .frame(maxWidth: UIScreen.main.minLength * 3 / 4)
                .onTapGesture {
                    showAliasInFullScreen()
                }
            }
        }
        .disabled(viewModel.isUpdating)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating
        }
        .onReceive(Just(viewModel.isRefreshed)) { isRefreshed in
            if isRefreshed {
                onUpdateAlias(viewModel.alias)
                viewModel.handledIsRefreshedBoolean()
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

//        ZStack {
//            NavigationLink(isActive: $showingAliasContacts,
//                           destination: { AliasContactsView(alias: viewModel.alias, session: viewModel.session) },
//                           label: { EmptyView() })
//            ScrollView {
//                Group {
//                    CreationDateSection(alias: viewModel.alias)
//                        .fullScreenCover(isPresented: $showingAliasFullScreen) {
//                            AliasEmailView(email: viewModel.alias.email)
//                        }
//                        .sheet(isPresented: $showingAliasEmailSheet) {
//                            AliasEmailView(email: viewModel.alias.email)
//                        }
//                    Divider()
//                    MailboxesSection(viewModel: viewModel)
//                    Divider()
//                    NameSection(viewModel: viewModel)
//                    Divider()
//                    NotesSection(viewModel: viewModel)
//                    Divider()
//                    ActivitiesSection(viewModel: viewModel, copiedText: $copiedText)
//                }
//                .padding(.horizontal)
//                .disabled(viewModel.isUpdating || viewModel.isRefreshing)
//            }
//            .introspectScrollView { scrollView in
//                scrollView.refreshControl = viewModel.refreshControl
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarItems(trailing: trailingButton)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                VStack(spacing: 0) {
//                    Text(viewModel.alias.email)
//                        .font(.headline)
//                        .truncationMode(.middle)
//                        .frame(maxWidth: 280)
//                        .foregroundColor(viewModel.alias.enabled ? .primary : .secondary)
//
//                    HStack {
//                        if viewModel.alias.pinned {
//                            Image(systemName: "bookmark.fill")
//                                .foregroundColor(.accentColor)
//
//                            Divider()
//                        }
//
//                        Text(viewModel.alias.enabled ? "Active" : "Inactive")
//                            .foregroundColor(viewModel.alias.enabled ? .primary : .secondary)
//                    }
//                    .font(.footnote)
//                }
//                .onTapGesture {
//                    showAliasInFullScreen()
//                }
//            }
//        }
//        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
//            showingLoadingAlert = isUpdating
//        }
//        .onReceive(Just(viewModel.isRefreshed)) { isRefreshed in
//            if isRefreshed {
//                onUpdateAlias(viewModel.alias)
//                viewModel.handledIsRefreshedBoolean()
//            }
//        }
//        .onReceive(Just(viewModel.isDeleted)) { isDeleted in
//            if isDeleted {
//                onDeleteAlias(viewModel.alias)
//            }
//        }
//        .onAppear {
//            viewModel.getMoreActivitiesIfNeed(currentActivity: nil)
//        }
//        .alertToastLoading(isPresenting: $showingLoadingAlert)
//        .alertToastCopyMessage(isPresenting: showingCopyAlert, message: copiedText)
//        .alertToastError($viewModel.error)
//        .alert(isPresented: $showingDeletionAlert) {
//            Alert.deleteConfirmation(alias: viewModel.alias) {
//                viewModel.delete()
//            }
//        }
    }
//
//    private var trailingButton: some View {
//        Menu(content: {
//            Section {
//                Button(action: {
//                    Vibration.soft.vibrate()
//                    copiedText = viewModel.alias.email
//                    UIPasteboard.general.string = viewModel.alias.email
//                }, label: {
//                    Label.copy
//                })
//
//                Button(action: {
//                    showAliasInFullScreen()
//                }, label: {
//                    Label.enterFullScreen
//                })
//            }
//
//            Section {
//                Button(action: {
//                    Vibration.soft.vibrate()
//                    showingAliasContacts = true
//                }, label: {
//                    Label.sendEmail
//                })
//            }
//
//            Section {
//                if viewModel.alias.enabled {
//                    Button(action: {
//                        viewModel.toggle()
//                    }, label: {
//                        Label.deactivate
//                    })
//                } else {
//                    Button(action: {
//                        viewModel.toggle()
//                    }, label: {
//                        Label.activate
//                    })
//                }
//
//                if viewModel.alias.pinned {
//                    Button(action: {
//                        viewModel.update(option: .pinned(false))
//                    }, label: {
//                        Label.unpin
//                    })
//                } else {
//                    Button(action: {
//                        viewModel.update(option: .pinned(true))
//                    }, label: {
//                        Label.pin
//                    })
//                }
//            }
//
//            Section {
//                DeleteMenuButton {
//                    showingDeletionAlert = true
//                }
//            }
//        }, label: {
//            Image(systemName: "ellipsis.circle")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 24, height: 24)
//        })
//    }

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

    var body: some View {
        let alias = viewModel.alias
        Section(content: {
            Button(action: enterFullScreen) {
                Text("Enter full screen")
            }
        }, header: {
            HStack {
                button(
                    action: {
                        Vibration.soft.vibrate()
                        viewModel.update(option: .pinned(!alias.pinned))
                    },
                    image: Image(systemName: alias.pinned ? "bookmark.slash" : "bookmark.fill"),
                    text: Text(alias.pinned ? "unpin" : "pin")
                )
                    .foregroundColor(alias.pinned ? .red : .slPurple)

                button(
                    action: {
                        Vibration.soft.vibrate()
                        viewModel.toggle()
                    },
                    image: Image(systemName: alias.enabled ? "circle.dashed" : "checkmark.circle.fill"),
                    text: Text(alias.enabled ? "deactivate" : "activate")
                )
                    .foregroundColor(alias.enabled ? .red : .slPurple)

                button(
                    action: {
                        Vibration.soft.vibrate()
                        copiedText = viewModel.alias.email
                        UIPasteboard.general.string = viewModel.alias.email
                    },
                    image: Image(systemName: "doc.on.doc.fill"),
                    text: Text("copy")
                )
                    .foregroundColor(.slPurple)

                NavigationLink(
                    isActive: $showingContacts,
                    destination: {
                        AliasContactsView(alias: viewModel.alias, session: viewModel.session)
                    },
                    label: {
                        button(
                            action: {
                                showingContacts = true
                            },
                            image: Image(systemName: "paperplane.fill"),
                            text: Text("send email")
                        )
                            .foregroundColor(.slPurple)
                    })
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
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
}
private struct EmailAndStatusSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel

    var body: some View {
        let alias = viewModel.alias

        Section(content: {
            Button(action: {
                Vibration.soft.vibrate()
                viewModel.update(option: .pinned(!alias.pinned))
            }, label: {
                Label(title: {
                    Text(alias.pinned ? "Unpin" : "Pin")
                }, icon: {
                    Image(systemName: alias.pinned ? "bookmark.slash" : "bookmark.fill")
                })
            })
                .foregroundColor(alias.pinned ? .red : .slPurple)

            Button(action: {
                Vibration.soft.vibrate()
                viewModel.toggle()
            }, label: {
                Label(title: {
                    Text(alias.enabled ? "Deactivate" : "Activate")
                }, icon: {
                    Image(systemName: alias.enabled ? "circle.dashed" : "checkmark.circle.fill")
                })
            })
                .foregroundColor(alias.enabled ? .red : .slPurple)
        }, header: {
            Text("\(alias.creationDateString) (\(alias.relativeCreationDateString))")
        })
    }
}

private struct MailboxesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingExplication = false
    @State private var selectedSheet: Sheet?

    private enum Sheet {
        case edit, view
    }

    var body: some View {
        let showingSheet = Binding<Bool>(get: {
            selectedSheet != nil
        }, set: { showing in
            if !showing {
                selectedSheet = nil
            }
        })
        VStack(alignment: .leading) {
            HStack {
                Text("Mailboxes")
                    .font(.title2)
                    .fontWeight(.bold)

                if !showingExplication {
                    Button(action: {
                        withAnimation {
                            showingExplication = true
                        }
                    }, label: {
                        Text("ⓘ")
                    })
                }

                Spacer()

                Button(action: {
                    selectedSheet = .edit
                }, label: {
                    Text("Edit")
                })
            }
            .padding(.top, 8)
            .padding(.bottom, showingExplication ? 2 : 8)

            if showingExplication {
                Text("The mailboxes that receive emails sent to this alias")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            VStack(alignment: .leading) {
                ForEach(0..<min(3, viewModel.alias.mailboxes.count), id: \.self) { index in
                    let mailbox = viewModel.alias.mailboxes[index]
                    Text(mailbox.email)
                }
            }

            if viewModel.alias.mailboxes.count > 3 {
                HStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                    Spacer()
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    selectedSheet = .view
                }
            }
        }
        .sheet(isPresented: showingSheet) {
            switch selectedSheet {
            case .edit:
                EditMailboxesView(viewModel: viewModel)
            case .view:
                AllMailboxesView(viewModel: viewModel)
            default: EmptyView()
            }
        }
    }
}

private struct AllMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mailboxes")) {
                    ForEach(viewModel.alias.mailboxes, id: \.id) { mailbox in
                        Text(mailbox.email)
                    }
                }
            }
            .navigationBarTitle(viewModel.alias.email)
            .navigationBarItems(leading: closeButton)
        }
        .accentColor(.slPurple)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

private struct NameSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingExplication = false
    @State private var showingEditDisplayNameView = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Display name")
                    .font(.title2)
                    .fontWeight(.bold)

                if !showingExplication {
                    Button(action: {
                        withAnimation {
                            showingExplication = true
                        }
                    }, label: {
                        Text("ⓘ")
                    })
                }

                Spacer()

                Button(action: {
                    showingEditDisplayNameView = true
                }, label: {
                    Text(viewModel.alias.name == nil ? "Add" : "Edit")
                })
            }
            .padding(.top, 8)
            .padding(.bottom, showingExplication ? 2 : 8)

            if showingExplication {
                Text("Your display name when sending emails from this alias")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            if let name = viewModel.alias.name {
                Text(name)
            }
        }
        .sheet(isPresented: $showingEditDisplayNameView) {
            EditDisplayNameView(viewModel: viewModel)
        }
    }
}

private struct NotesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingExplication = false
    @State private var showingEditNotesView = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notes")
                    .font(.title2)
                    .fontWeight(.bold)

                if !showingExplication {
                    Button(action: {
                        withAnimation {
                            showingExplication = true
                        }
                    }, label: {
                        Text("ⓘ")
                    })
                }

                Spacer()

                Button(action: {
                    showingEditNotesView = true
                }, label: {
                    Text(viewModel.alias.note == nil ? "Add" : "Edit")
                })
            }
            .padding(.top, 8)
            .padding(.bottom, showingExplication ? 2 : 8)

            if showingExplication {
                Text("Something to remind you about the usage of this alias")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            if let notes = viewModel.alias.note {
                Text(notes)
            }
        }
        .sheet(isPresented: $showingEditNotesView) {
            EditNotesView(viewModel: viewModel)
        }
    }
}

private struct ActivitiesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @Binding var copiedText: String?

    var body: some View {
        LazyVStack {
            HStack {
                Text("Last 14 days activities")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 8)

            if viewModel.alias.noActivities {
                Text("No activities")
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Spacer()
                    section(action: .forward,
                            count: viewModel.alias.forwardCount)
                    Spacer()
                    Divider()
                    Spacer()
                    section(action: .reply,
                            count: viewModel.alias.replyCount)
                    Spacer()
                    Divider()
                    section(action: .block,
                            count: viewModel.alias.blockCount)
                    Spacer()
                }

                ForEach(0..<viewModel.activities.count, id: \.self) { index in
                    let activity = viewModel.activities[index]
                    ActivityView(copiedText: $copiedText, activity: activity)
                        .padding(.vertical, 4)
                        .onAppear {
                            viewModel.getMoreActivitiesIfNeed(currentActivity: activity)
                        }

                    if index < viewModel.activities.count - 1 {
                        Divider()
                    }
                }

                if viewModel.isLoadingActivities {
                    ProgressView()
                        .padding()
                }
            }
        }
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack {
            Label {
                Text(action.title)
                    .fontWeight(.semibold)
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

// MARK: - Edit modal views
private struct EditMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var selectedIds: [Int] = []

    var body: some View {
        NavigationView {
            Group {
                if !viewModel.mailboxes.isEmpty {
                    mailboxesList
                }
            }
            .navigationTitle(viewModel.alias.email)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
            .disabled(viewModel.isUpdating)
        }
        .accentColor(.slPurple)
        .onAppear {
            selectedIds = viewModel.alias.mailboxes.map { $0.id }
            viewModel.getMailboxes()
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
        .onReceive(Just(viewModel.isLoadingMailboxes)) { isLoadingMailboxes in
            showingLoadingAlert = isLoadingMailboxes
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

    private var doneButton: some View {
        Button(action: {
            viewModel.update(option: .mailboxIds(selectedIds))
        }, label: {
            Text("Done")
        })
    }

    private var mailboxesList: some View {
        Form {
            Section(header: Text("Mailboxes")) {
                ForEach(viewModel.mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                        Spacer()
                        if selectedIds.contains(mailbox.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedIds.contains(mailbox.id) && selectedIds.count > 1 {
                            selectedIds.removeAll { $0 == mailbox.id }
                        } else if !selectedIds.contains(mailbox.id) {
                            selectedIds.append(mailbox.id)
                        }
                    }
                }
            }
        }
    }
}

private struct EditDisplayNameView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var displayName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display name")) {
                    if #available(iOS 15, *) {
                        AutoFocusTextField(text: $displayName)
                    } else {
                        TextField("", text: $displayName)
                            .labelsHidden()
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                }
            }
            .navigationTitle(viewModel.alias.email)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            displayName = viewModel.alias.name ?? ""
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

    private var doneButton: some View {
        Button(action: {
            viewModel.update(option: .name(displayName.isEmpty ? nil : displayName))
        }, label: {
            Text("Done")
        })
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
                Section(header: Text("Notes")) {
                    if #available(iOS 15, *) {
                        AutoFocusTextEditor(text: $notes)
                            .disabled(viewModel.isUpdating)
                    } else {
                        TextEditor(text: $notes)
                            .autocapitalization(.sentences)
                            .disableAutocorrection(true)
                            .disabled(viewModel.isUpdating)
                    }
                }
            }
            .navigationTitle(viewModel.alias.email)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
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

    private var doneButton: some View {
        Button(action: {
            viewModel.update(option: .note(notes.isEmpty ? nil : notes))
        }, label: {
            Text("Done")
        })
            .disabled(viewModel.isUpdating)
    }
}

struct AliasEmailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var originalBrightness: CGFloat = 0.5
    @State private var percentage: Double = 0.5
    let email: String

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(verbatim: email)
                    .font(.system(size: (percentage + 1) * 24))
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Text("A")
                    Slider(value: $percentage)
                    Text("A")
                        .font(.title)
                }
            }
            .accentColor(.slPurple)
            .padding()
            .navigationBarItems(leading: closeButton)
            .onAppear {
                originalBrightness = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1.0)
            }
            .onDisappear {
                UIScreen.main.brightness = originalBrightness
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}
