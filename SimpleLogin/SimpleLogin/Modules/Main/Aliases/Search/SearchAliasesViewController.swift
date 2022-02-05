//
//  SearchAliasesViewController.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import SwiftUI
import UIKit

final class SearchAliasesViewController: BaseViewController {
    private let viewModel: SearchAliasesViewModel

    init(session: Session) {
        viewModel = .init(session: session)
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
        navigationItem.titleView = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false

        let searchAliasesResultView = SearchAliasesResultView(viewModel: viewModel)
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
