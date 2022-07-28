//
//  KeyboardContentView.swift
//  Keyboard Extension
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import Combine
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

final class KeyboardContentViewModel: BaseSessionViewModel, ObservableObject {
    @AppStorage(kKeyboardExtensionMode, store: .shared)
    private var keyboardExtensionMode: KeyboardExtensionMode = .all
    @Published private(set) var aliases = [Alias]()
    @Published private(set) var isLoading = false
    @Published private(set) var moreToLoad = true
    @Published private(set) var createdAlias: Alias?
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
                                  option: keyboardExtensionMode == .pinned ? .pinned : nil)
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
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    override func refresh() {
        isLoading = true
        session.client.getAliases(apiKey: session.apiKey, page: 0, option: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    self.error = nil
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] aliasArray in
                guard let self = self else { return }
                self.aliases = aliasArray.aliases
                self.currentPage = 1
                self.canLoadMorePages = aliasArray.aliases.count == kDefaultPageSize
            }
            .store(in: &cancellables)
    }

    func random(mode: RandomMode) {
        guard !isLoading else { return }
        isLoading = true
        session.client.randomAlias(apiKey: session.apiKey,
                                   options: AliasRandomOptions(mode: mode))
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
            } receiveValue: { [weak self] randomAlias in
                guard let self = self else { return }
                self.refresh()
                self.createdAlias = randomAlias
            }
            .store(in: &cancellables)
    }

    func handleCreatedAlias() {
        createdAlias = nil
    }
}
