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
    @State private var showingSearchView = false
    @State private var showingRandomAliasBottomSheet = false
    @State private var showingCreateAliasView = false
    @State private var showingCopyAliasHud = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AliasesViewToolbar(selectedStatus: $selectedStatus,
                                   onSearch: { showingSearchView.toggle() },
                                   onRandomAlias: { showingRandomAliasBottomSheet.toggle() },
                                   onCreateAlias: { showingCreateAliasView.toggle() })

                EmptyView()
                    .fullScreenCover(isPresented: $showingSearchView) {
                        AliasesSearchView()
                    }

                EmptyView()
                    .fullScreenCover(isPresented: $showingCreateAliasView) {
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
                                        showingCopyAliasHud = true
                                        UIPasteboard.general.string = alias.email
                                    },
                                    onSendMail: {
                                        print("Send mail: \(alias.email)")
                                    })
                                    .padding(.horizontal, 4)
                                    .toast(isPresenting: $showingCopyAliasHud) {
                                        AlertToast(displayMode: .hud,
                                                   type: .systemImage("doc.on.doc", .green),
                                                   title: "Copied",
                                                   subTitle: alias.email,
                                                   style: nil)
                                    }
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
            .actionSheet(isPresented: $showingRandomAliasBottomSheet) {
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
