//
//  AliasDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasDetailView: View {
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingActionSheet = false

    init(alias: Alias) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias))
    }

    var body: some View {
        ScrollView {
            Divider()
            CreationDateSection(alias: viewModel.alias)
            Divider()
            MailboxesSection(alias: viewModel.alias)
            Divider()
            NameSection(name: viewModel.alias.name)
            Divider()
            NotesSection(notes: viewModel.alias.note)
            Divider()
            ActivityView(alias: viewModel.alias)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            actionSheet
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: trailingButton)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.alias.email)
                    .font(.headline)
                    .truncationMode(.middle)
                    .frame(maxWidth: 280)
                    .foregroundColor(viewModel.alias.enabled ? .primary : .secondary)
            }
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

        var buttons: [ActionSheet.Button] = []
        buttons.append(copyAction)
        if viewModel.alias.enabled {
            buttons.append(deactiveAction)
        } else {
            buttons.append(activateAction)
        }
        buttons.append(.cancel())

        return ActionSheet(title: Text(""),
                           message: Text(viewModel.alias.email),
                           buttons: buttons)
    }
}

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
    @State private var dummyItem = ""
    let alias: Alias

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
                    //
                }, label: {
                    Text("Edit")
                })
            }
            .padding(.vertical, 8)

            VStack(alignment: .leading) {
                ForEach(0..<min(3, alias.mailboxes.count), id: \.self) { index in
                    let mailbox = alias.mailboxes[index]
                    Text(mailbox.email)
                }
            }

            if alias.mailboxes.count > 3 {
                HStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct NameSection: View {
    @State private var dummyItem = ""
    let name: String?

    var body: some View {
        VStack {
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
                    //
                }, label: {
                    Text(name == nil ? "Add" : "Edit")
                })
            }
            .padding(.vertical, 8)

            if let name = name {
                Text(name)
            }
        }
    }
}

private struct NotesSection: View {
    @State private var dummyItem = ""
    let notes: String?

    var body: some View {
        VStack {
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
                    //
                }, label: {
                    Text(notes == nil ? "Add" : "Edit")
                })
            }
            .padding(.vertical, 8)

            if let notes = notes {
                Text(notes)
            }
        }
    }
}

private struct ActivityView: View {
    let alias: Alias

    var body: some View {
        HStack {
            section(action: .forward, count: alias.forwardCount)
            section(action: .reply, count: alias.replyCount)
            section(action: .block, count: alias.blockCount)
        }
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack {
            Text(action.title)
            Text("\(count)")
        }
    }
}

struct AliasDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AliasDetailView(alias: .claypool)
        }
    }
}
