//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @Environment(\.toastMessage) private var toastMessage
    @StateObject private var viewModel: AliasesViewModel
    @State private var selectedStatus: AliasStatus = .all
    @State private var showSearchView = false
    @State private var showRandomAliasBottomSheet = false
    @State private var showCreateAliasView = false

    init(apiKey: ApiKey, client: SLClient) {
        _viewModel = StateObject(wrappedValue: .init(apiKey: apiKey, client: client))
    }

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
                        ForEach(viewModel.aliases, id: \.id) { alias in
                            NavigationLink(destination: Text(alias.email)) {
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
                            }
                            .buttonStyle(FlatLinkButtonStyle())
                        }
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
            viewModel.fetchMoreAliases()
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
