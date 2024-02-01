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
    @EnvironmentObject private var reachabilityObserver: ReachabilityObserver
    @Environment(\.managedObjectContext) private var managedObjectContext
    let session: Session
    let onUpdateAlias: (Alias) -> Void
    let onDeleteAlias: (Alias) -> Void
    let onUpgrade: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = SearchAliasesViewController(session: session,
                                                         reachabilityObserver: reachabilityObserver,
                                                         managedObjectContext: managedObjectContext,
                                                         onUpdateAlias: onUpdateAlias,
                                                         onDeleteAlias: onDeleteAlias, 
                                                         onUpgrade: onUpgrade)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.tintColor = .slPurple
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController,
                                context: Context) {}
}
