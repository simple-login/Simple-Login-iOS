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
    private var createAliasViewMode: CreateAliasView.Mode?

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                self.createAliasViewMode = try await extractMode()
                self.setUpUI()
            } catch {
                alert(error: error) { [unowned self] in
                    self.dismiss()
                }
            }
        }
    }

    private func setUpUI() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        if let apiKey = KeychainService.shared.getApiKey(),
           let baseURL = URL(string: Preferences.shared.apiUrl) {
            let apiService = APIService(baseURL: baseURL,
                                        session: .init(configuration: config),
                                        printDebugInformation: true)
            setSession(session: .init(apiKey: apiKey, apiService: apiService))
        } else {
            setSession(session: nil)
        }
    }

    private func setSession(session: Session?) {
        let subView: UIView
        if let session = session {
            let createAliasView = CreateAliasView(
                session: session,
                mode: createAliasViewMode,
                onCreateAlias: { [unowned self] alias in
                    self.handleAliasCreation(alias: alias)
                },
                onCancel: { [unowned self] in
                    self.dismiss()
                },
                onOpenMyAccount: nil)
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

    private func extractMode() async throws -> CreateAliasView.Mode? {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return nil
        }

        var fallbackText = ""
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            for itemProvider in attachments {
                do {
                    if let url = try await itemProvider.loadItem(forTypeIdentifier: "public.url") as? URL {
                        return .url(url)
                    }
                } catch {
                    // Printing out error for information
                    // ignore and fallback to text later
                    print(error.localizedDescription)
                }

                if let text = try await itemProvider.loadItem(forTypeIdentifier: "public.text") as? String {
                    if !text.isEmpty {
                        fallbackText = text
                    }

                    if let url = text.firstUrl() {
                        return .url(url)
                    }
                }
            }
        }

        return .text(fallbackText)
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

    private func dismiss() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
