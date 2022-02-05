//
//  SearchAliasesViewController.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import SimpleLoginPackage
import SwiftUI
import UIKit

final class SearchAliasesViewController: BaseViewController {
    private let viewModel: SearchAliasesViewModel
    let onUpdateAlias: (Alias) -> Void

    init(session: Session, onUpdateAlias: @escaping (Alias) -> Void) {
        self.viewModel = .init(session: session)
        self.onUpdateAlias = onUpdateAlias
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search term"
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.autocapitalizationType = .none
        navigationItem.titleView = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false

        let searchAliasesResultView = SearchAliasesResultView(
            viewModel: viewModel,
            onSelect: { [unowned self] alias in
                self.showAliasDetail(alias)
            },
            onSendMail: { [unowned self] alias in
                self.showAliasContacts(alias)
            },
            onUpdate: onUpdateAlias)
        let hostingController = UIHostingController(rootView: searchAliasesResultView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }

    private func showAliasDetail(_ alias: Alias) {
        let aliasDetailView = AliasDetailView(
            alias: alias,
            session: viewModel.session,
            onUpdateAlias: { [unowned self] updatedAlias in
                self.onUpdateAlias(updatedAlias)
            },
            onDeleteAlias: {

            })
        let hostingController = UIHostingController(rootView: aliasDetailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }

    private func showAliasContacts(_ alias: Alias) {
        let aliasContactsView = AliasContactsView(alias: alias, session: viewModel.session)
        let hostingController = UIHostingController(rootView: aliasContactsView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension SearchAliasesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(term: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}
