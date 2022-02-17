//
//  DomainDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct DomainDetailView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel: DomainDetailViewModel
    @State private var showingLoadingAlert = false

    init(domain: CustomDomain, session: Session) {
        _viewModel = StateObject(wrappedValue: .init(domain: domain,
                                                     session: session))
    }

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let domain = viewModel.domain
        ScrollView {
            Group {
                CreationDateSection(domain: domain)
                Divider()
                CatchAllSection(viewModel: viewModel)
                Divider()
                DefaultDisplayNameSection(viewModel: viewModel)
                Divider()
                RandomPrefixSection(viewModel: viewModel)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(domain.domainName)
                        .font(.headline)
                        .truncationMode(.middle)
                        .frame(maxWidth: 280)
                        .foregroundColor(domain.verified ? .primary : .secondary)

                    HStack {
                        Image(systemName: domain.verified ? "checkmark.seal.fill" : "checkmark.seal")
                            .foregroundColor(domain.verified ? .green : .gray)

                        Divider()

                        Text("\(domain.aliasCount) alias(es)")
                    }
                    .font(.footnote)
                }
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
    }
}

// MARK: - Sections
private struct CreationDateSection: View {
    let domain: CustomDomain

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Creation date")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 8)

            Text("\(domain.creationDateString) (\(domain.relativeCreationDateString))")
        }
    }
}

private struct CatchAllSection: View {
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingExplication = false
    @State private var showingEditMailboxes = false
    @State private var selectedSheet: Sheet?

    private enum Sheet {
        case edit, view
    }

    var body: some View {
        let domain = viewModel.domain
        let showingSheet = Binding<Bool>(get: {
            selectedSheet != nil
        }, set: { showing in
            if !showing {
                selectedSheet = nil
            }
        })
        VStack(alignment: .leading) {
            HStack {
                Text("Auto create/on the fly alias")
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

                if viewModel.catchAll {
                    Button(action: {
                        selectedSheet = .edit
                    }, label: {
                        Text("Edit")
                    })
                }
            }
            .padding(.top, 8)
            .padding(.bottom, showingExplication ? 2 : 8)

            if showingExplication {
                Text("Simply use anything@\(domain.domainName) next time you need an alias: it'll be automatically created the first time it receives an email. To have more fine-grained control, you can also define auto create rules.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            Toggle("Catch all", isOn: $viewModel.catchAll.animation())
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))

            if viewModel.catchAll {
                Text("Auto-created aliases are automatically owned by the following mailboxes")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)

                VStack(alignment: .leading) {
                    ForEach(0..<min(3, viewModel.domain.mailboxes.count), id: \.self) { index in
                        let mailbox = viewModel.domain.mailboxes[index]
                        Text(mailbox.email)
                    }
                }

                if viewModel.domain.mailboxes.count > 3 {
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

private struct EditMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var selectedIds: [Int] = []

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            Group {
                if !viewModel.mailboxes.isEmpty {
                    mailboxesList
                }
            }
            .navigationTitle(viewModel.domain.domainName)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
            .disabled(viewModel.isLoading)
        }
        .accentColor(.slPurple)
        .onAppear {
            selectedIds = viewModel.domain.mailboxes.map { $0.id }
            viewModel.getMailboxes()
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
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
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
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

private struct AllMailboxesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: DomainDetailViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mailboxes")) {
                    ForEach(viewModel.domain.mailboxes, id: \.id) { mailbox in
                        Text(mailbox.email)
                    }
                }
            }
            .navigationBarTitle(viewModel.domain.domainName)
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

private struct DefaultDisplayNameSection: View {
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingExplication = false
    @State private var showingEditDisplayNameView = false

    var body: some View {
        let domain = viewModel.domain
        VStack(alignment: .leading) {
            HStack {
                Text("Default display name")
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
                    Text(viewModel.domain.name == nil ? "Add" : "Edit")
                })
            }
            .padding(.top, 8)
            .padding(.bottom, showingExplication ? 2 : 8)

            if showingExplication {
                Text("Default display name for aliases created with \(domain.domainName) unless overwritten by the alias display name")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            if let name = domain.name {
                Text(name)
            }
        }
        .sheet(isPresented: $showingEditDisplayNameView) {
            EditDisplayNameView(viewModel: viewModel)
        }
    }
}

private struct EditDisplayNameView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var displayName = ""

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            Form {
                Section(header: Text("Display name"),
                        footer: Text("You can remove display name by leaving this field blank")) {
                    if #available(iOS 15, *) {
                        AutoFocusTextField(text: $displayName)
                            .modifier(ClearButtonModeModifier(mode: .whileEditing))
                    } else {
                        TextField("", text: $displayName)
                            .labelsHidden()
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .modifier(ClearButtonModeModifier(mode: .whileEditing))
                    }
                }
            }
            .navigationTitle(viewModel.domain.domainName)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            displayName = viewModel.domain.name ?? ""
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.isUpdated)) { isUpdated in
            if isUpdated {
                presentationMode.wrappedValue.dismiss()
                viewModel.handledIsUpdatedBoolean()
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
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

private struct RandomPrefixSection: View {
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingExplication = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Random prefix generation")
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
            }
            .padding(.vertical, 8)

            if showingExplication {
                Text("Add a random prefix for this domain when creating a new alias")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            Toggle("Enabled", isOn: $viewModel.randomPrefixGeneration)
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))
        }
    }
}
