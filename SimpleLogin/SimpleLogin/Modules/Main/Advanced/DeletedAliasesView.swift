//
//  DeletedAliasesView.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 20/10/2022.
//

import SimpleLoginPackage
import SwiftUI

struct DeletedAliasesView: View {
    @StateObject private var viewModel: DeletedAliasesViewModel

    init(session: Session, domain: CustomDomain) {
        _viewModel = StateObject(wrappedValue: .init(session: session,
                                                     domain: domain))
    }

    var body: some View {
        Form {
            if viewModel.noAliases {
                Text("No deleted aliases")
                    .font(.body.italic())
                    .foregroundColor(.secondary)
            } else {
                Section(content: {
                    ForEach(viewModel.deletedAliases, id: \.alias) { alias in
                        VStack(alignment: .leading) {
                            Text(alias.alias)
                            if let relativeDeletedDateString = viewModel.relativeDeletedDateString(alias: alias) {
                                Text(relativeDeletedDateString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }, header: {
                    Text("\(viewModel.deletedAliases.count) deleted alias(es)")
                })
            }
        }
        .task { await viewModel.refresh(force: false) }
        .refreshable { await viewModel.refresh(force: true) }
        .animation(.default, value: viewModel.deletedAliases.count)
        .navigationTitle(viewModel.domain.domainName)
        .navigationBarTitleDisplayMode(.large)
        .alertToastLoading(isPresenting: $viewModel.isLoading)
        .alertToastError($viewModel.error)
    }
}
