//
//  AliasesView.swift
//  Keyboard Extension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct AliasesView: View {
    @StateObject private var viewModel: AliasesViewModel
    let onTap: (Alias) -> Void

    init(session: Session, onTap: @escaping (Alias) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.onTap = onTap
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
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
                                    onTap(alias)
                                }
                                .onAppear {
                                    viewModel.getMoreAliasesIfNeed(currentAlias: alias)
                                }
                        }
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal, 44)
                .onAppear {
                    viewModel.getMoreAliasesIfNeed(currentAlias: nil)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width * 0.6)
    }
}

private struct AliasView: View {
    let alias: Alias

    var body: some View {
        HStack(spacing: 0) {
            Color(alias.enabled ? .slPurple : (.darkGray))
                .frame(width: 4)

            Label {
                Text(alias.email)
            } icon: {
                Image(systemName: alias.pinned ? "bookmark.fill" : "")
                    .foregroundColor(.slPurple)
            }
            .font(.callout)
            .padding(10)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(alias.enabled ? Color.slPurple.opacity(0.05) : Color(.darkGray).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// swiftlint:disable let_var_whitespace
final class AliasesViewModel: BaseSessionViewModel, ObservableObject {
    @AppStorage(kKeyboardExtensionMode, store: .shared)
    private var keyboardExtensionMode: KeyboardExtensionMode = .all
    @Published private(set) var aliases = [Alias]()
    @Published private(set) var isLoading = false
    @Published private(set) var moreToLoad = true
    @Published private(set) var error: Error?

    private var currentPage = 0
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()

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
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey,
                                  page: currentPage,
                                  pinned: keyboardExtensionMode == .pinned)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases.append(contentsOf: aliasArray.aliases)
                self.currentPage += 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }

    override func refresh() {
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey, page: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases = aliasArray.aliases
                self.currentPage = 1
                self.canLoadMorePages = aliasArray.aliases.count == 20
            }
            .store(in: &cancellables)
    }
}
