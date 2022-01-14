//
//  DomainDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import SimpleLoginPackage
import SwiftUI

struct DomainDetailView: View {
    @StateObject private var viewModel: DomainDetailViewModel

    init(domain: CustomDomain) {
        _viewModel = StateObject(wrappedValue: .init(domain: domain))
    }

    var body: some View {
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
//            .disabled(viewModel.isUpdating || viewModel.isRefreshing)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: trailingButton)
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
    }

    private var trailingButton: some View {
        Button(action: {
//            selectedSheet = .actions
        }, label: {
            Image(systemName: "ellipsis")
        })
            .frame(minWidth: 24, minHeight: 24)
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

    var body: some View {
        let domain = viewModel.domain
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

//                Button(action: {
//                    showingEditDisplayNameView = true
//                }, label: {
//                    Text(viewModel.alias.name == nil ? "Add" : "Edit")
//                })
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
//                        selectedSheet = .view
                    }
                }
            }
        }
//        .sheet(isPresented: $showingEditDisplayNameView) {
//            EditDisplayNameView(viewModel: viewModel)
//        }
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
//        .sheet(isPresented: $showingEditDisplayNameView) {
//            EditDisplayNameView(viewModel: viewModel)
//        }
    }
}

private struct RandomPrefixSection: View {
    @ObservedObject var viewModel: DomainDetailViewModel
    @State private var showingExplication = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Random Prefix Generation")
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

struct DomainDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DomainDetailView(domain: .verified)
        }
    }
}
