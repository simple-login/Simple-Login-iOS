//
//  AliasesView.swift
//  Keyboard Extension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @ObservedObject var viewModel: KeyboardContentViewModel
    let onSelectAlias: (Alias) -> Void

    var body: some View {
        if let error = viewModel.error {
            VStack(alignment: .center) {
                Text(error.safeLocalizedDescription)
                Button(action: {
                    viewModel.refresh()
                }, label: {
                    Text("Retry")
                })
            }
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 6) {
                    ForEach(viewModel.aliases, id: \.id) { alias in
                        AliasView(alias: alias)
                            .onTapGesture {
                                onSelectAlias(alias)
                            }
                            .onAppear {
                                viewModel.getMoreAliasesIfNeed(currentAlias: alias)
                            }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.top)
                .padding(.bottom, 44) // Avoid tab indicator
            }
            .padding(.horizontal, 44)
            .onAppear {
                viewModel.getMoreAliasesIfNeed(currentAlias: nil)
            }
        }
    }
}

private struct AliasView: View {
    let alias: Alias

    var body: some View {
        Label(title: {
            Text(alias.email)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }, icon: {
            if alias.pinned {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.slPurple)
            }
        })
        .font(.callout)
        .frame(maxWidth: .infinity, alignment: .center)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(alias.enabled ? .primary : .secondary)
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
