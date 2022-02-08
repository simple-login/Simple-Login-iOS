//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AlertToast
import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @StateObject private var viewModel: AliasesViewModel
    @State private var showingRandomAliasActionSheet = false
    @State private var showingUpdatingAlert = false
    @State private var showingSearchView = false
    @State private var showingCreateView = false
    @State private var copiedEmail: String?
    @State private var createdAlias: Alias?
    @State private var selectedDestinationMode: AliasNavigationLinkDestination.Mode?

    enum Modal {
        case search, create
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

        let showingDestination = Binding<Bool>(get: {
            selectedDestinationMode != nil
        }, set: { isShowing in
            if !isShowing {
                selectedDestinationMode = nil
            }
        })
        NavigationView {
            ZStack {
                NavigationLink(
                    isActive: showingDestination,
                    destination: {
                        AliasNavigationLinkDestination(
                            viewModel: viewModel,
                            mode: selectedDestinationMode ?? .contacts(.ccohen))
                            .onAppear {
                                selectedDestinationMode = nil
                            }
                    },
                    label: {
                        EmptyView()
                    })

                List {
                    ForEach(viewModel.filteredAliases, id: \.id) { alias in
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
                                selectedDestinationMode = .contacts(alias)
                            },
                            onToggle: {
                                viewModel.toggle(alias: alias)
                            })
                            .onAppear {
                                viewModel.getMoreAliasesIfNeed(currentAlias: alias)
                            }
                            .onTapGesture {
                                selectedDestinationMode = .detail(alias)
                            }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .animation(.default)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        AliasesViewToolbar(selectedStatus: $viewModel.selectedStatus,
                                           onSearch: { showingSearchView = true },
                                           onRandomAlias: { showingRandomAliasActionSheet.toggle() },
                                           onCreateAlias: { showingCreateView = true })
                    }
                }
                .introspectTableView { tableView in
                    tableView.refreshControl = viewModel.refreshControl
                }
                .actionSheet(isPresented: $showingRandomAliasActionSheet) {
                    randomAliasActionSheet
                }
                .sheet(isPresented: $showingSearchView) {
                    SearchAliasesView(
                        session: viewModel.session,
                        onUpdateAlias: { updatedAlias in
                            viewModel.update(alias: updatedAlias)
                        },
                        onDeleteAlias: { deletedAlias in
                            viewModel.delete(alias: deletedAlias)
                        })
                        .forceDarkModeIfApplicable()
                }
            }

            DetailPlaceholderView(systemIconName: "at",
                                  message: "Select an alias to see its details here")
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
                .forceDarkModeIfApplicable()
        }
        .toast(isPresenting: showingCopiedEmailAlert) {
            AlertToast.copiedAlert(content: copiedEmail)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(viewModel.error)
        }
        .toast(isPresenting: $showingUpdatingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingCreatedAliasAlert) {
            AlertToast(displayMode: .alert,
                       type: .complete(.green),
                       title: "Created",
                       subTitle: createdAlias?.email ?? "")
        }
    }

    private var randomAliasActionSheet: ActionSheet {
        ActionSheet(title: Text("New alias"),
                    message: Text("Randomly create an alias"),
                    buttons: [
                        .default(Text("By random words")) {
                            viewModel.random(mode: .word)
                        },
                        .default(Text("By UUID")) {
                            viewModel.random(mode: .uuid)
                        },
                        .cancel(Text("Cancel"))
                    ])
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

private struct AliasNavigationLinkDestination: View {
    @ObservedObject var viewModel: AliasesViewModel
    let mode: Mode

    enum Mode {
        case detail(Alias), contacts(Alias)
    }

    var body: some View {
        switch mode {
        case .detail(let alias):
            AliasDetailView(
                alias: alias,
                session: viewModel.session,
                onUpdateAlias: { updatedAlias in
                    viewModel.update(alias: updatedAlias)
                },
                onDeleteAlias: {
                    viewModel.delete(alias: alias)
                })
        case .contacts(let alias):
            AliasContactsView(alias: alias, session: viewModel.session)
        }
    }
}

private struct AliasesViewToolbar: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticEffectEnabled = true
    @Binding var selectedStatus: AliasStatus
    let onSearch: () -> Void
    let onRandomAlias: () -> Void
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
                .padding(.horizontal, 16)

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
            }

            Spacer()
                .frame(width: 24)

            Button(action: onRandomAlias) {
                Image(systemName: "shuffle")
            }

            Spacer()
                .frame(width: 24)

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
