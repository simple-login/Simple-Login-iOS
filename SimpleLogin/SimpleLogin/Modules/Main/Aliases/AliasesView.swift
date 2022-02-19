//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @StateObject private var viewModel: AliasesViewModel
    @State private var showingUpdatingAlert = false
    @State private var showingSearchView = false
    @State private var showingCreateView = false
    @State private var showingDeleteConfirmationAlert = false
    @State private var copiedEmail: String?
    @State private var createdAlias: Alias?
    @State private var selectedAlias: Alias?
    @State private var aliasToShowDetails: Alias?
    @State private var selectedLink: Link?

    enum Modal {
        case search, create
    }

    enum Link {
        case details, contacts
    }

    init(session: Session) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
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
                .listStyle(.plain)
                .animation(.default)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        AliasesViewToolbar(selectedStatus: $viewModel.selectedStatus,
                                           onSearch: { showingSearchView = true },
                                           onRandomByWord: { viewModel.random(mode: .word) },
                                           onRandomByUuid: { viewModel.random(mode: .uuid) },
                                           onCreateAlias: { showingCreateView = true })
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
        .onAppear {
            viewModel.getMoreAliasesIfNeed(currentAlias: nil)
        }
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingUpdatingAlert = isUpdating
        }
        .sheet(isPresented: $showingCreateView) {
            CreateAliasView(
                session: viewModel.session,
                url: nil,
                onCreateAlias: { createdAlias in
                    self.createdAlias = createdAlias
                    self.viewModel.refresh()
                },
                onCancel: nil
            )
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
                if hapticFeedbackEnabled {
                    Vibration.soft.vibrate()
                }
                copiedEmail = alias.email
                UIPasteboard.general.string = alias.email
            },
            onSendMail: {
                selectedAlias = alias
                selectedLink = .contacts
            },
            onToggle: {
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

private struct AliasesViewToolbar: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticEffectEnabled = true
    @Binding var selectedStatus: AliasStatus
    let onSearch: () -> Void
    let onRandomByWord: () -> Void
    let onRandomByUuid: () -> Void
    let onCreateAlias: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: $selectedStatus) {
                ForEach(AliasStatus.allCases, id: \.self) { status in
                    Text(status.description)
                        .tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()

            Divider()
                .fixedSize()
                .padding(.horizontal)

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
            }

            Menu(content: {
                Button(action: onRandomByWord) {
                    Text("Random an alias by word")
                }

                Button(action: onRandomByUuid) {
                    Text("Random an alias by UUID")
                }
            }, label: {
                Image(systemName: "shuffle")
            })
                .padding(.horizontal)

            Button(action: {
                if hapticEffectEnabled {
                    Vibration.light.vibrate()
                }
                onCreateAlias()
            }, label: {
                Image(systemName: "plus")
            })
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}
