//
//  SearchAliasesResultView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import AlertToast
import SimpleLoginPackage
import SwiftUI

struct SearchAliasesResultView: View {
    @ObservedObject var viewModel: SearchAliasesViewModel
    @AppStorage(kHapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    @State private var copiedEmail: String?
    var onSelectAlias: (Alias) -> Void

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingCopiedEmailAlert = Binding<Bool>(get: {
            copiedEmail != nil
        }, set: { isShowing in
            if !isShowing {
                copiedEmail = nil
            }
        })

        ScrollView {
            if viewModel.aliases.isEmpty,
               !viewModel.isLoading,
               let lastSearchTerm = viewModel.lastSearchTerm {
                Text("No results for \"\(lastSearchTerm)\"")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack {
                    ForEach(viewModel.aliases, id: \.id) { alias in
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
                                
                            },
                            onToggle: {

                            })
                            .padding(.horizontal, 4)
                            .onTapGesture {
                                onSelectAlias(alias)
                            }
                            .onAppear {
                                viewModel.getMoreAliasesIfNeed(currentAlias: alias)
                            }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.endEditing()
            }
        )
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(viewModel.error)
        }
        .toast(isPresenting: showingCopiedEmailAlert) {
            AlertToast.copiedAlert(content: copiedEmail)
        }
    }
}
