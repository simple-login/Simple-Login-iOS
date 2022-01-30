//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Thanh-Nhon Nguyen on 26/01/2022.
//

import SimpleLoginPackage
import SwiftUI
import UIKit

final class ShareViewController: UIViewController {
    private var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        extractUrl { [weak self] url in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.url = url
                self.setUpUI()
            }
        }
    }

    private func setUpUI() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        if let apiKey = KeychainService.shared.getApiKey(),
           let client = SLClient(session: URLSession(configuration: config),
                                 baseUrlString: Preferences.shared.apiUrl) {
            setSession(session: .init(apiKey: apiKey, client: client))
        } else {
            setSession(session: nil)
        }
    }

    private func setSession(session: Session?) {
        let subView: UIView
        if let session = session {
            let createAliasView = CreateAliasView(
                session: session,
                url: url,
                onCreateAlias: { [unowned self] alias in
                    self.handleAliasCreation(alias: alias)
                },
                onCancel: { [unowned self] in
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                })
            let hostingController = UIHostingController(rootView: createAliasView)
            subView = hostingController.view
            addChild(hostingController)
            hostingController.didMove(toParent: self)
        } else {
            let hostingController = UIHostingController(rootView: NoSessionView())
            subView = hostingController.view
            addChild(hostingController)
            hostingController.didMove(toParent: self)
        }

        subView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subView)
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: view.topAnchor),
            subView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func extractUrl(completion: @escaping (URL?) -> Void) {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion(nil)
            return
        }
        for item in extensionItems {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { object, _ in
                        if let url = object as? URL {
                            completion(url)
                            return
                        }
                    }
                }
            }
        }
        completion(nil)
    }

    private func handleAliasCreation(alias: Alias) {
        let alert = UIAlertController(title: "Alias created",
                                      message: "\(alias.email) is created and can be used.",
                                      preferredStyle: .alert)
        let copyAndCloseAction = UIAlertAction(title: "Copy & close", style: .default) { [unowned self] _ in
            UIPasteboard.general.string = alias.email
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        alert.addAction(copyAndCloseAction)

        let closeAction = UIAlertAction(title: "Close", style: .cancel) { [unowned self] _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        alert.addAction(closeAction)
        alert.view.tintColor = .slPurple
        present(alert, animated: true, completion: nil)
    }
}
