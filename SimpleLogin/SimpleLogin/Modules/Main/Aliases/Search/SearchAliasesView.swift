//
//  SearchAliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct SearchAliasesView: UIViewControllerRepresentable {
    let session: Session
    let onUpdateAlias: (Alias) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = SearchAliasesViewController(session: session, onUpdateAlias: onUpdateAlias)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.tintColor = .slPurple
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
