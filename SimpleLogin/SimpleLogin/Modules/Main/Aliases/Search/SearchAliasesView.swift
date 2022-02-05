//
//  SearchAliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import SwiftUI

struct SearchAliasesView: UIViewControllerRepresentable {
    let session: Session

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = SearchAliasesViewController(session: session)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.tintColor = .slPurple
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
