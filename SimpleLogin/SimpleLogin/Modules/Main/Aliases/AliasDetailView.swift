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
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingActionSheet = false
    private let refresher = Refresher()
    var onUpdateAlias: (Alias) -> Void

    init(alias: Alias, onUpdateAlias: @escaping (Alias) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias))
        self.onUpdateAlias = onUpdateAlias
    }

    var body: some View {
        ZStack {
            ScrollView {
                Group {
                    CreationDateSection(alias: viewModel.alias)
                    Divider()
                    MailboxesSection(viewModel: viewModel)
                    Divider()
                    NameSection(viewModel: viewModel)
                    Divider()
                    NotesSection(viewModel: viewModel)
                    Divider()
                    ActivitiesSection(viewModel: viewModel)
                }
                .padding(.horizontal)
                .disabled(viewModel.isUpdating || viewModel.isRefreshing)
            }
            .introspectScrollView { scrollView in
                scrollView.refreshControl = refresher.control
            }

            if viewModel.isUpdating {
                ProgressView()
                    .animation(.default)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            actionSheet
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
            }
        }
        .onReceive(Just(viewModel.isRefreshing)) { isRefreshing in
            if !isRefreshing {
                refresher.endRefreshing()
            }
        }
        .onDisappear {
            onUpdateAlias(viewModel.alias)
        }
        .onAppear {
            refresher.parent = self
            let control = UIRefreshControl()
            control.addTarget(refresher, action: #selector(Refresher.beginRefreshing), for: .valueChanged)
            refresher.control = control
            viewModel.getMoreActivitiesIfNeed(session: session, currentActivity: nil)
        }
    }

    private var trailingButton: some View {
        Button(action: {
            showingActionSheet = true
        }, label: {
            Image(systemName: "ellipsis")
        })
            .frame(minWidth: 24, minHeight: 24)
    }

    private var actionSheet: ActionSheet {
        let copyAction = ActionSheet.Button.default(Text("Copy")) {
            // TODO: Copy to clipboard
            print("Copy \(viewModel.alias.email)")
        }

        let activateAction = ActionSheet.Button.default(Text("Activate")) {
            viewModel.toggle(session: session)
        }

        let deactiveAction = ActionSheet.Button.default(Text("Deactivate")) {
            viewModel.toggle(session: session)
        }

        let pinAction = ActionSheet.Button.default(Text("Pin")) {
            viewModel.update(session: session,
                             option: .pinned(true))
        }

        let unpinAction = ActionSheet.Button.default(Text("Unpin")) {
            viewModel.update(session: session,
                             option: .pinned(false))
        }

        var buttons: [ActionSheet.Button] = []
        buttons.append(copyAction)
        if viewModel.alias.enabled {
            buttons.append(deactiveAction)
        } else {
            buttons.append(activateAction)
        }
        if viewModel.alias.pinned {
            buttons.append(unpinAction)
        } else {
            buttons.append(pinAction)
        }
        buttons.append(.cancel())

        return ActionSheet(title: Text(""),
                           message: Text(viewModel.alias.email),
                           buttons: buttons)
    }

    private func refresh() {
        viewModel.refresh(session: session)
    }
}

private extension AliasDetailView {
    class Refresher {
        var parent: AliasDetailView?
        var control: UIRefreshControl?

        @objc
        func beginRefreshing() {
            parent?.refresh()
        }

        func endRefreshing() {
            control?.endRefreshing()
        }
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
    @State private var showingEditMailboxesView = false
    @State private var showingAllMailboxes = false

    var body: some View {
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
                    showingEditMailboxesView = true
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
                    showingAllMailboxes = true
                }
                .sheet(isPresented: $showingAllMailboxes) {
                    AllMailboxesView(viewModel: viewModel)
                }
            }
        }
        .sheet(isPresented: $showingEditMailboxesView) {
            EditMailboxesView(viewModel: viewModel)
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
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel

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
                            viewModel.getMoreActivitiesIfNeed(session: session, currentActivity: activity)
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
    @State private var didPressDoneButton = false
    @State private var selectedIds: [Int] = []

    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if viewModel.isLoadingMailboxes {
                        ProgressView()
                    } else if !viewModel.mailboxes.isEmpty {
                        mailboxesList
                    } else {
                        EmptyView()
                            .onAppear {
                                viewModel.getMailboxes(session: session)
                            }
                    }
                }

                if viewModel.isUpdating {
                    ProgressView()
                        .animation(.default)
                }
            }
            .navigationTitle(viewModel.alias.email)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            selectedIds = viewModel.alias.mailboxes.map { $0.id }
            viewModel.getMailboxes(session: session)
        }
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            if didPressDoneButton && !isUpdating && viewModel.error == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
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
            didPressDoneButton = true
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
    @State private var didPressDoneButton = false
    @State private var displayName = ""

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Display name")) {
                        if #available(iOS 15, *) {
                            AutoFocusTextField(text: $displayName)
                        } else {
                            TextField("", text: $displayName)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                        }
                    }
                }

                if viewModel.isUpdating {
                    ProgressView()
                        .animation(.default)
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
            if didPressDoneButton && !isUpdating && viewModel.error == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
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
            didPressDoneButton = true
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
    @State private var didPressDoneButton = false
    @State private var notes = ""

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Notes"),
                            footer: Text(viewModel.error?.description ?? "")) {
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

                if viewModel.isUpdating {
                    ProgressView()
                        .animation(.default)
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
            if didPressDoneButton && !isUpdating && viewModel.error == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
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
            didPressDoneButton = true
            viewModel.update(session: session,
                             option: .note(notes.isEmpty ? nil : notes))
        }, label: {
            Text("Done")
        })
            .disabled(viewModel.isUpdating)
    }
}

// MARK: - Previews
struct AliasDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AliasDetailView(alias: .claypool) { _ in }
        }
    }
}
