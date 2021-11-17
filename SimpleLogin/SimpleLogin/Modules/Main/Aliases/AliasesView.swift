//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AlertToast
import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AliasesViewModel()
    @State private var selectedStatus: AliasStatus = .all
    @State private var showingRandomAliasBottomSheet = false
    @State private var selectedModal: Modal?
    @State private var copiedEmail: String?

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

        NavigationView {
            ScrollView {
                LazyVStack {
                    // Upper spacer
                    Spacer()
                        .frame(height: 8)

                    ForEach(viewModel.aliases, id: \.id) { alias in
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    AliasesViewToolbar(selectedStatus: $selectedStatus,
                                       onSearch: { selectedModal = .search },
                                       onRandomAlias: { showingRandomAliasBottomSheet.toggle() },
                                       onCreateAlias: { selectedModal = .create })
                }
            }
            .actionSheet(isPresented: $showingRandomAliasBottomSheet) {
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
        .toast(isPresenting: showingCopiedEmailAlert) {
            AlertToast(displayMode: .alert,
                       type: .systemImage("doc.on.doc", .secondary),
                       title: "Copied",
                       subTitle: copiedEmail ?? "")
        }
    }

    private var randomAliasActionSheet: ActionSheet {
        ActionSheet(title: Text("New alias"),
                    message: Text("Randomly create an alias"),
                    buttons: [
                        .default(Text("By random words")) {
                            print("random words")
                        },
                        .default(Text("By UUID")) {
                            print("uuid")
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
