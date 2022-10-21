//
//  KeyboardContentView.swift
//  Keyboard Extension
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SimpleLoginPackage
import SwiftUI

struct KeyboardContentView: View {
    @StateObject private var viewModel: KeyboardContentViewModel
    let onSelectAlias: (Alias) -> Void

    init(session: Session, onTap: @escaping (Alias) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.onSelectAlias = onTap
    }

    var body: some View {
        ZStack {
            Color(.systemGray5)
            if let error = viewModel.error {
                VStack(alignment: .center, spacing: 20) {
                    Text(error.safeLocalizedDescription)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button(action: {
                        viewModel.refresh()
                    }, label: {
                        Label("Retry", systemImage: "gobackward")
                    })
                        .foregroundColor(.slPurple)
                }
                .padding()
            } else {
                if let createdAlias = viewModel.createdAlias {
                    CreatedAliasView(viewModel: viewModel, alias: createdAlias, onSelectAlias: onSelectAlias)
                } else {
                    TabView {
                        AliasesView(viewModel: viewModel, onSelectAlias: onSelectAlias)
                        RandomAliasesView(viewModel: viewModel)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width * 0.6)
    }
}

final class KeyboardContentViewModel: ObservableObject {
    @AppStorage(kKeyboardExtensionMode, store: .shared)
    private var keyboardExtensionMode: KeyboardExtensionMode = .all
    @Published private(set) var aliases = [Alias]()
    @Published private(set) var isLoading = false
    @Published private(set) var moreToLoad = true
    @Published private(set) var createdAlias: Alias?
    @Published private(set) var error: Error?

    private var currentPage = 0
    private var canLoadMorePages = true
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func getMoreAliasesIfNeed(currentAlias alias: Alias?) {
        guard let alias = alias else {
            getMoreAliases()
            return
        }

        let thresholdIndex = aliases.index(aliases.endIndex, offsetBy: -1)
        if aliases.firstIndex(where: { $0.id == alias.id }) == thresholdIndex {
            getMoreAliases()
        }
    }

    private func getMoreAliases() {
        guard !isLoading && canLoadMorePages else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let aliases = try await getAliases(page: currentPage)
                self.aliases += aliases
                self.currentPage += 1
                self.canLoadMorePages = aliases.count == kDefaultPageSize
            } catch {
                self.error = error
            }
        }
    }

    func refresh() {
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let aliases = try await getAliases(page: 0)
                self.aliases = aliases
                self.currentPage = 1
                self.canLoadMorePages = aliases.count == kDefaultPageSize
                self.error = nil
            } catch {
                self.error = error
            }
        }
    }

    private func getAliases(page: Int) async throws -> [Alias] {
        let option = GetAliasesOption.filter(keyboardExtensionMode == .pinned ? .pinned : nil)
        let getAliasesEndpoint = GetAliasesEndpoint(apiKey: session.apiKey.value,
                                                    page: page,
                                                    option: option)
        return try await session.execute(getAliasesEndpoint).aliases
    }

    func random(mode: RandomMode) {
        guard !isLoading else { return }
        Task { @MainActor in
            defer { isLoading = false }
            isLoading = true
            do {
                let randomAliasEndpoint = RandomAliasEndpoint(apiKey: session.apiKey.value,
                                                              note: nil,
                                                              mode: mode,
                                                              hostname: nil)
                let alias = try await session.execute(randomAliasEndpoint)
                self.createdAlias = alias
                self.refresh()
            } catch {
                self.error = error
            }
        }
    }

    func handleCreatedAlias() {
        createdAlias = nil
    }
}
