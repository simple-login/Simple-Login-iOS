//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @EnvironmentObject private var session: Session
    @Environment(\.toastMessage) private var toastMessage
    @StateObject private var viewModel = AliasesViewModel()
    @State private var selectedStatus: AliasStatus = .all
    @State private var showSearchView = false
    @State private var showRandomAliasBottomSheet = false
    @State private var showCreateAliasView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AliasesViewToolbar(selectedStatus: $selectedStatus,
                                   onSearch: { showSearchView.toggle() },
                                   onRandomAlias: { showRandomAliasBottomSheet.toggle() },
                                   onCreateAlias: { showCreateAliasView.toggle() })

                EmptyView()
                    .fullScreenCover(isPresented: $showSearchView) {
                        AliasesSearchView()
                    }

                EmptyView()
                    .fullScreenCover(isPresented: $showCreateAliasView) {
                        CreateAliasView()
                    }

                ScrollView {
                    LazyVStack {
                        // Upper spacer
                        Spacer()
                            .frame(height: 8)

                        ForEach(viewModel.aliases, id: \.id) { alias in
                            NavigationLink(destination:
                                            AliasDetailView(alias: alias) { updatedAlias in
                                viewModel.update(alias: updatedAlias)
                            }) {
                                AliasCompactView(
                                    alias: alias,
                                    onCopy: {
                                        toastMessage.wrappedValue = "Copied \(alias.email)"
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

                        // Lower spacer
                        Spacer()
                            .frame(height: 8)
                    }
                }
            }
            .navigationTitle("Aliases")
            .navigationBarHidden(true)
            .ignoresSafeArea(.all, edges: .top)
            .actionSheet(isPresented: $showRandomAliasBottomSheet) {
                randomAliasActionSheet
            }
        }
        .onAppear {
            viewModel.getMoreAliasesIfNeed(session: session, currentAlias: nil)
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
