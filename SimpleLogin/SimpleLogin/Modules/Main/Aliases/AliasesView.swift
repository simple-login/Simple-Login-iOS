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
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AliasesViewModel()
    @State private var showingRandomAliasActionSheet = false
    @State private var showingUpdatingAlert = false
    @State private var selectedModal: Modal?
    @State private var copiedEmail: String?
    private let refreshControl = UIRefreshControl()

    enum Modal {
        case search, create
    }

    var body: some View {
        let showingCopiedEmailAlert = Binding<Bool>(get: {
            copiedEmail != nil
        }, set: { isShowing in
            if !isShowing {
                copiedEmail = nil
            }
        })

        let showingFullScreenModal = Binding<Bool>(get: {
            selectedModal != nil
        }, set: { isShowing in
            if !isShowing {
                selectedModal = nil
            }
        })

        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredAliases, id: \.id) { alias in
                        NavigationLink(destination:
                                        AliasDetailView(
                                            alias: alias,
                                            onUpdateAlias: { updatedAlias in
                                                viewModel.update(alias: updatedAlias)
                                            },
                                            onDeleteAlias: {
                                                viewModel.delete(alias: alias)
                                            })
                        ) {
                            AliasCompactView(
                                alias: alias,
                                onCopy: {
                                    copiedEmail = alias.email
                                    UIPasteboard.general.string = alias.email
                                },
                                onSendMail: {
                                    print("Send mail: \(alias.email)")
                                },
                                onToggle: {
                                    viewModel.toggle(alias: alias, session: session)
                                })
                                .padding(.horizontal, 4)
                                .onAppear {
                                    viewModel.getMoreAliasesIfNeed(session: session, currentAlias: alias)
                                }
                        }
                        .buttonStyle(FlatLinkButtonStyle())
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.vertical, 8)
                .animation(.default)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    AliasesViewToolbar(selectedStatus: $viewModel.selectedStatus,
                                       onSearch: { selectedModal = .search },
                                       onRandomAlias: { showingRandomAliasActionSheet.toggle() },
                                       onCreateAlias: { selectedModal = .create })
                }
            }
            .introspectScrollView { scrollView in
                refreshControl.addAction(UIAction { _ in
                    viewModel.refresh(session: session)
                }, for: .valueChanged)
                scrollView.refreshControl = refreshControl
            }
            .actionSheet(isPresented: $showingRandomAliasActionSheet) {
                randomAliasActionSheet
            }
            .fullScreenCover(isPresented: showingFullScreenModal) {
                switch selectedModal {
                case .search: SearchAliasesView()
                case .create: CreateAliasView()
                default: EmptyView()
                }
            }
        }
        .onAppear {
            viewModel.getMoreAliasesIfNeed(session: session, currentAlias: nil)
        }
        .onReceive(Just(viewModel.isRefreshing)) { isRefreshing in
            if !isRefreshing {
                refreshControl.endRefreshing()
            }
        }
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingUpdatingAlert = isUpdating
        }
        .toast(isPresenting: showingCopiedEmailAlert) {
            AlertToast(displayMode: .alert,
                       type: .systemImage("doc.on.doc", .secondary),
                       title: "Copied",
                       subTitle: copiedEmail ?? "")
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
        .toast(isPresenting: $showingUpdatingAlert) {
            AlertToast(type: .loading)
        }
    }

    private var randomAliasActionSheet: ActionSheet {
        ActionSheet(title: Text("New alias"),
                    message: Text("Randomly create an alias"),
                    buttons: [
                        .default(Text("By random words")) {
                            viewModel.random(mode: .word, session: session)
                        },
                        .default(Text("By UUID")) {
                            viewModel.random(mode: .uuid, session: session)
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

struct AliasesViewToolbar: View {
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

            Button(action: onCreateAlias) {
                Image(systemName: "plus")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}
