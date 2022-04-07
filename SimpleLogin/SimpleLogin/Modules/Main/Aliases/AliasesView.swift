//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import CoreData
import Introspect
import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @StateObject private var viewModel: AliasesViewModel
    @Binding private var createdAlias: Alias?
    @State private var showingUpdatingAlert = false
    @State private var showingSearchView = false
    @State private var showingDeleteConfirmationAlert = false
    @State private var copiedEmail: String?
    @State private var selectedAlias: Alias?
    @State private var aliasToShowDetails: Alias?
    @State private var selectedLink: Link?

    enum Modal {
        case search, create
    }

    enum Link {
        case details, contacts
    }

    init(session: Session,
         reachabilityObserver: ReachabilityObserver,
         managedObjectContext: NSManagedObjectContext,
         createdAlias: Binding<Alias?>) {
        let viewModel = AliasesViewModel(session: session,
                                         reachabilityObserver: reachabilityObserver,
                                         managedObjectContext: managedObjectContext)
        _viewModel = StateObject(wrappedValue: viewModel)
        _createdAlias = createdAlias
    }

    var body: some View {
        let showingCopiedEmailAlert = Binding<Bool>(get: {
            copiedEmail != nil
        }, set: { isShowing in
            if !isShowing {
                copiedEmail = nil
            }
        })

        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingCreatedAliasAlert = Binding<Bool>(get: {
            createdAlias != nil
        }, set: { isShowing in
            if !isShowing {
                createdAlias = nil
            }
        })

        NavigationView {
            ZStack {
                NavigationLink(
                    tag: Link.details,
                    selection: $selectedLink,
                    destination: {
                        AliasDetailWrapperView(
                            selectedAlias: $selectedAlias,
                            session: viewModel.session,
                            onUpdateAlias: { updatedAlias in
                                viewModel.update(alias: updatedAlias)
                            },
                            onDeleteAlias: { deletedAlias in
                                viewModel.remove(alias: deletedAlias)
                            })
                            .onAppear {
                                if UIDevice.current.userInterfaceIdiom != .phone {
                                    selectedLink = nil
                                }
                            }
                    },
                    label: {
                        EmptyView()
                    })

                NavigationLink(
                    tag: Link.contacts,
                    selection: $selectedLink,
                    destination: {
                        if let selectedAlias = selectedAlias {
                            AliasContactsView(alias: selectedAlias, session: viewModel.session)
                                .onAppear {
                                    if UIDevice.current.userInterfaceIdiom != .phone {
                                        selectedLink = nil
                                    }
                                }
                        } else {
                            EmptyView()
                        }
                    },
                    label: {
                        EmptyView()
                    })

                List {
                    ForEach(viewModel.filteredAliases, id: \.id) { alias in
                        // TODO: Workaround a SwiftUI bug that doesn't update AliasCompactView's context menu
                        // https://stackoverflow.com/a/70159934
                        if alias.pinned {
                            aliasCompactView(for: alias)
                        } else {
                            aliasCompactView(for: alias)
                        }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .ignoresSafeArea(.keyboard)
                .listStyle(.plain)
                .animation(.default)
                .navigationBarTitleDisplayMode(.inline)
                .offlineLabelled(reachable: viewModel.reachabilityObserver.reachable)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("", selection: $viewModel.selectedStatus) {
                            ForEach(AliasStatus.allCases, id: \.self) { status in
                                Text(status.description)
                                    .tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Vibration.light.vibrate()
                            showingSearchView = true
                        }, label: {
                            Image(systemName: "magnifyingglass")
                        })
                    }
                }
                .introspectTableView { tableView in
                    tableView.refreshControl = viewModel.refreshControl
                }
                .sheet(isPresented: $showingSearchView) {
                    SearchAliasesView(
                        session: viewModel.session,
                        onUpdateAlias: { updatedAlias in
                            viewModel.update(alias: updatedAlias)
                        },
                        onDeleteAlias: { deletedAlias in
                            viewModel.remove(alias: deletedAlias)
                        })
                }
            }

            DetailPlaceholderView.aliasDetails
        }
        .slNavigationView()
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingUpdatingAlert = isUpdating
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            if  !isLoading, UIDevice.current.userInterfaceIdiom != .phone, selectedAlias == nil {
                selectedAlias = viewModel.filteredAliases.first
                selectedLink = .details
            }
        }
        .onReceive(Just(createdAlias)) { createdAlias in
            if let createdAlias = createdAlias {
                viewModel.handleCreatedAlias(createdAlias)
            }
        }
        .alert(isPresented: $showingDeleteConfirmationAlert) {
            guard let selectedAlias = selectedAlias else {
                return Alert(title: Text("selectedAlias is nil"))
            }

            return Alert.deleteConfirmation(alias: selectedAlias) {
                viewModel.delete(alias: selectedAlias)
            }
        }
        .alertToastLoading(isPresenting: $showingUpdatingAlert)
        .alertToastCopyMessage(isPresenting: showingCopiedEmailAlert, message: copiedEmail)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
        .alertToastCompletionMessage(isPresenting: showingCreatedAliasAlert,
                                     title: "Created",
                                     subTitle: createdAlias?.email ?? "")
    }

    private func aliasCompactView(for alias: Alias) -> some View {
        AliasCompactView(
            alias: alias,
            onCopy: {
                Vibration.soft.vibrate()
                copiedEmail = alias.email
                UIPasteboard.general.string = alias.email
            },
            onSendMail: {
                Vibration.soft.vibrate()
                selectedAlias = alias
                selectedLink = .contacts
            },
            onToggle: {
                Vibration.soft.vibrate()
                viewModel.toggle(alias: alias)
            },
            onPin: {
                viewModel.update(alias: alias, option: .pinned(true))
            },
            onUnpin: {
                viewModel.update(alias: alias, option: .pinned(false))
            },
            onDelete: {
                selectedAlias = alias
                showingDeleteConfirmationAlert = true
            })
            .onAppear {
                viewModel.getMoreAliasesIfNeed(currentAlias: alias)
            }
            .onTapGesture {
                selectedAlias = alias
                selectedLink = .details
            }
    }
}

enum AliasStatus: CustomStringConvertible, CaseIterable {
    case all, active, inactive

    var description: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .inactive: return "Inactive"
        }
    }
}
