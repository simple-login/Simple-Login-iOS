//
//  SearchAliasesView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import CoreData
import SimpleLoginPackage
import SwiftUI

struct SearchAliasesView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var managedObjectContext
    let session: Session
    let onUpdateAlias: (Alias) -> Void
    let onDeleteAlias: (Alias) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = SearchAliasesViewController(session: session,
                                                         managedObjectContext: managedObjectContext,
                                                         onUpdateAlias: onUpdateAlias,
                                                         onDeleteAlias: onDeleteAlias)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.tintColor = .slPurple
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController,
                                context: Context) {}
}
