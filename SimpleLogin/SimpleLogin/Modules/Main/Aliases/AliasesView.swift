//
//  AliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
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
                        ForEach(0...100, id: \.self) { number in
                            NavigationLink(destination: Text("#\(number)")) {
                                if number.isMultiple(of: 2) {
                                    AliasCompactView(
                                        alias: .claypool,
                                        onCopy: {
                                            print("Copy: \(number)")
                                        },
                                        onSendMail: {
                                            print("Send mail: \(number)")
                                        })
                                        .padding(.horizontal, 4)
                                } else {
                                    AliasCompactView(
                                        alias: .ccohen,
                                        onCopy: {
                                            print("Copy: \(number)")
                                        },
                                        onSendMail: {
                                            print("Send mail: \(number)")
                                        })
                                        .padding(.horizontal, 4)
                                }
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
