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

// swiftlint:disable file_length
struct AliasDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var showingDeletionAlert = false
    @State private var showingAliasEmailSheet = false
    @State private var showingAliasContacts = false
    @State private var selectedSheet: Sheet?
    @State private var copiedText: String?
    var onUpdateAlias: (Alias) -> Void
    var onDeleteAlias: () -> Void

    private enum Sheet {
        case actions, activity(AliasActivity)
    }

    init(alias: Alias,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
        self.onUpdateAlias = onUpdateAlias
        self.onDeleteAlias = onDeleteAlias
    }

    var body: some View {
        let showingSheet = Binding<Bool>(get: {
            selectedSheet != nil
        }, set: { isShowing in
            if !isShowing {
                selectedSheet = nil
            }
        })

        let showingCopyAlert = Binding<Bool>(get: {
            copiedText != nil
        }, set: { isShowing in
            if !isShowing {
                copiedText = nil
            }
        })

        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        ZStack {
            NavigationLink(isActive: $showingAliasContacts,
                           destination: { AliasContactsView(alias: viewModel.alias, session: viewModel.session) },
                           label: { EmptyView() })
            ScrollView {
                Group {
                    CreationDateSection(alias: viewModel.alias)
                        .sheet(isPresented: $showingAliasEmailSheet) {
                            AliasEmailView(email: viewModel.alias.email)
                                .forceDarkModeIfApplicable()
                        }
                    Divider()
                    MailboxesSection(viewModel: viewModel)
                    Divider()
                    NameSection(viewModel: viewModel)
                    Divider()
                    NotesSection(viewModel: viewModel)
                    Divider()
                    ActivitiesSection(viewModel: viewModel) { activity in
                        selectedSheet = .activity(activity)
                    }
                }
                .padding(.horizontal)
                .disabled(viewModel.isUpdating || viewModel.isRefreshing)
            }
            .introspectScrollView { scrollView in
                scrollView.refreshControl = viewModel.refreshControl
            }
        }
        .actionSheet(isPresented: showingSheet) {
            switch selectedSheet {
            case .activity(let activity):
                return activitySheet(activity: activity)
            default:
                return actionsSheet
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: trailingButton)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(viewModel.alias.email)
                        .font(.headline)
                        .truncationMode(.middle)
                        .frame(maxWidth: 280)
                        .foregroundColor(viewModel.alias.enabled ? .primary : .secondary)

                    HStack {
                        if viewModel.alias.pinned {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.accentColor)

                            Divider()
                        }

                        Text(viewModel.alias.enabled ? "Active" : "Inactive")
                            .foregroundColor(viewModel.alias.enabled ? .primary : .secondary)
                    }
                    .font(.footnote)
                }
                .onTapGesture {
                    showingAliasEmailSheet = true
                }
            }
        }
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
                onDeleteAlias()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.getMoreActivitiesIfNeed(currentActivity: nil)
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastCopyMessage(isPresenting: showingCopyAlert, message: copiedText)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
        .alert(isPresented: $showingDeletionAlert) {
            deletionAlert
        }
    }

    private var trailingButton: some View {
        Button(action: {
            selectedSheet = .actions
        }, label: {
            Image(systemName: "ellipsis")
        })
            .frame(minWidth: 24, minHeight: 24)
    }

    private var actionsSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = []

        buttons.append(
            ActionSheet.Button.default(Text("Copy")) {
                if hapticFeedbackEnabled {
                    Vibration.soft.vibrate()
                }
                copiedText = viewModel.alias.email
                UIPasteboard.general.string = viewModel.alias.email
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Send email")) {
                if hapticFeedbackEnabled {
                    Vibration.soft.vibrate()
                }
                showingAliasContacts = true
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Enter Full Screen")) {
                showingAliasEmailSheet = true
            }
        )

        if viewModel.alias.enabled {
            buttons.append(
                ActionSheet.Button.default(Text("Deactivate")) {
                    viewModel.toggle()
                }
            )
        } else {
            buttons.append(
                ActionSheet.Button.default(Text("Activate")) {
                    viewModel.toggle()
                }
            )
        }

        if viewModel.alias.pinned {
            buttons.append(
                ActionSheet.Button.default(Text("Unpin")) {
                    viewModel.update(session: session,
                                     option: .pinned(false))
                }
            )
        } else {
            buttons.append(
                ActionSheet.Button.default(Text("Pin")) {
                    viewModel.update(session: session,
                                     option: .pinned(true))
                }
            )
        }

        buttons.append(
            ActionSheet.Button.destructive(Text("Delete")) {
                if hapticFeedbackEnabled {
                    Vibration.warning.vibrate(fallBackToOldSchool: true)
                }
                showingDeletionAlert = true
            }
        )

        buttons.append(.cancel())

        return ActionSheet(title: Text(""),
                           message: Text(viewModel.alias.email),
                           buttons: buttons)
    }

    private var deletionAlert: Alert {
        Alert(title: Text("Delete \(viewModel.alias.email)?"),
              message: Text("This can not be undone. Please confirm"),
              primaryButton: .destructive(Text("Yes, delete this alias")) {
            viewModel.delete()
        },
              secondaryButton: .cancel())
    }

    private func activitySheet(activity: AliasActivity) -> ActionSheet {
        var buttons: [ActionSheet.Button] = []

        buttons.append(
            ActionSheet.Button.default(Text("Copy reverse-alias (w/ display name)")) {
                copiedText = activity.reverseAlias
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Copy reverse-alias (w/o display name)")) {
                copiedText = activity.reverseAliasAddress
            }
        )

        buttons.append(
            ActionSheet.Button.default(Text("Open default email client")) {
                if let mailToUrl = URL(string: "mailto:\(activity.reverseAliasAddress)") {
                    UIApplication.shared.open(mailToUrl)
                }
            }
        )

        buttons.append(.cancel())

        let fromAddress = activity.action == .reply ? activity.from : activity.to
        let toAddress = activity.action == .reply ? activity.to : activity.from
        return ActionSheet(title: Text("Compose and send email"),
                           message: Text("From: \"\(fromAddress)\"\nTo: \"\(toAddress)\""),
                           buttons: buttons)
    }
}

// MARK: - Sections
private struct CreationDateSection: View {
    let alias: Alias

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Creation date")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 8)

            Text("\(alias.creationDateString) (\(alias.relativeCreationDateString))")
        }
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
                    .forceDarkModeIfApplicable()
            case .view:
                AllMailboxesView(viewModel: viewModel)
                    .forceDarkModeIfApplicable()
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
                .forceDarkModeIfApplicable()
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
                .forceDarkModeIfApplicable()
        }
    }
}

private struct ActivitiesSection: View {
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    var onSelectActivity: (AliasActivity) -> Void

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
                    ActivityView(activity: activity)
                        .padding(.vertical, 4)
                        .onAppear {
                            viewModel.getMoreActivitiesIfNeed(currentActivity: activity)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelectActivity(activity)
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
    let activity: AliasActivity

    var body: some View {
        HStack {
            Image(systemName: activity.action.iconSystemName)
                .foregroundColor(activity.action.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.action == .reply ? activity.to : activity.from)
                Text("\(activity.dateString) (\(activity.relativeDateString))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Edit modal views
private struct EditMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var selectedIds: [Int] = []

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.updatingError != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledUpdatingError()
            }
        })

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
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.updatingError)
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
            viewModel.update(session: session,
                             option: .mailboxIds(selectedIds))
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
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var displayName = ""

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.updatingError != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledUpdatingError()
            }
        })

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
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.updatingError)
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
            viewModel.update(session: session,
                             option: .name(displayName.isEmpty ? nil : displayName))
        }, label: {
            Text("Done")
        })
    }
}

private struct EditNotesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var notes = ""

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.updatingError != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledUpdatingError()
            }
        })

        NavigationView {
            Form {
                Section(header: Text("Notes")) {
                    if #available(iOS 15, *) {
                        AutoFocusTextEditor(text: $notes)
                            .disabled(viewModel.isUpdating)
                    } else {
                        TextEditor(text: $notes)
                            .autocapitalization(.words)
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
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.updatingError)
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
            viewModel.update(session: session,
                             option: .note(notes.isEmpty ? nil : notes))
        }, label: {
            Text("Done")
        })
            .disabled(viewModel.isUpdating)
    }
}

struct AliasEmailView: View {
    @State private var originalBrightness: CGFloat = 0.5
    @State private var percentage: Double = 0.5
    let email: String

    var body: some View {
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
        .onAppear {
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = CGFloat(1.0)
        }
        .onDisappear {
            UIScreen.main.brightness = originalBrightness
        }
    }
}
