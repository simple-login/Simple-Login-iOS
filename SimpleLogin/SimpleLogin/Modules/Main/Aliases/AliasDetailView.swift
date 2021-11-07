//
//  AliasDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasDetailView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingActionSheet = false

    init(alias: Alias) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias))
    }

    var body: some View {
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
        .onAppear {
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
            // TODO: Activate alias
            print("Activea \(viewModel.alias.email)")
        }

        let deactiveAction = ActionSheet.Button.default(Text("Deactivate")) {
            // TODO: Deactive alias
            print("Deactivea \(viewModel.alias.email)")
        }

        let pinAction = ActionSheet.Button.default(Text("Pin")) {
            // TODO: Pin alias
            print("Pin \(viewModel.alias.email)")
        }

        let unpinAction = ActionSheet.Button.default(Text("Unpin")) {
            // TODO: Unpin alias
            print("Unpin \(viewModel.alias.email)")
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
    @State private var showingEditMailboxesView = false
    @State private var dummyItem = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Mailboxes")
                    .font(.title2)
                    .fontWeight(.bold)

                Picker("ⓘ", selection: $dummyItem) {
                    Text("The mailboxes that receive emails sent to this alias")
                }
                .pickerStyle(MenuPickerStyle())

                Spacer()

                Button(action: {
                    showingEditMailboxesView = true
                }, label: {
                    Text("Edit")
                })
            }
            .padding(.vertical, 8)

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
            }
        }
        .sheet(isPresented: $showingEditMailboxesView) {
            EditMailboxesView(viewModel: viewModel)
        }
    }
}

private struct NameSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingEditDisplayNameView = false
    @State private var dummyItem = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Display name")
                    .font(.title2)
                    .fontWeight(.bold)

                Picker("ⓘ", selection: $dummyItem) {
                    Text("Your display name when sending emails from this alias")
                }
                .pickerStyle(MenuPickerStyle())

                Spacer()

                Button(action: {
                    showingEditDisplayNameView = true
                }, label: {
                    Text(viewModel.alias.name == nil ? "Add" : "Edit")
                })
            }
            .padding(.vertical, 8)

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
    @State private var showingEditNotesView = false
    @State private var dummyItem = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notes")
                    .font(.title2)
                    .fontWeight(.bold)

                Picker("ⓘ", selection: $dummyItem) {
                    Text("Something to remind you about the usage of this alias")
                }
                .pickerStyle(MenuPickerStyle())

                Spacer()

                Button(action: {
                    showingEditNotesView = true
                }, label: {
                    Text(viewModel.alias.note == nil ? "Add" : "Edit")
                })
            }
            .padding(.vertical, 8)

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
    @State private var selectedIds: [Int] = []

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoadingMailboxes {
                    ProgressView()
                } else if !viewModel.mailboxes.isEmpty {
                    mailboxesList
                } else {
                    // TODO: Reload mailboxes here
                }
            }
            .navigationTitle("Mailboxes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onAppear {
            selectedIds = viewModel.alias.mailboxes.map { $0.id }
            viewModel.getMailboxes(session: session)
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
        Button(action: {}, label: {
            Text("Done")
        })
    }

    private var mailboxesList: some View {
        List {
            Section(header: Text(viewModel.alias.email)) {
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
        .listStyle(InsetGroupedListStyle())
    }
}

private struct EditDisplayNameView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var displayName = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(viewModel.alias.email)) {
                    TextField("", text: $displayName)
                        .labelsHidden()
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Display name")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onAppear {
            displayName = viewModel.alias.name ?? ""
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
        Button(action: {}, label: {
            Text("Done")
        })
    }
}

private struct EditNotesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var notes = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(viewModel.alias.email)) {
                    TextEditor(text: $notes)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onAppear {
            notes = viewModel.alias.note ?? ""
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
        Button(action: {}, label: {
            Text("Done")
        })
    }
}

// MARK: - Previews
struct AliasDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AliasDetailView(alias: .claypool)
        }
    }
}
