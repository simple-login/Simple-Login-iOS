//
//  KeyboardViewController.swift
//  Keyboard Extension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import SimpleLoginPackage
import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private let nextKeyboardButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
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
            let contentView = KeyboardContentView(session: session) { [unowned self] alias in
                textDocumentProxy.insertText(alias.email)
            }
            let hostingController = UIHostingController(rootView: contentView)
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
        addNextButton()
        addDeleteButton()
    }

    private func addNextButton() {
        guard needsInputModeSwitchKey else { return }
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        nextKeyboardButton.tintColor = .slPurple
        nextKeyboardButton.addTarget(self,
                                     action: #selector(handleInputModeList(from:with:)),
                                     for: .allTouchEvents)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextKeyboardButton)
        NSLayoutConstraint.activate([
            nextKeyboardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }

    private func addDeleteButton() {
        deleteButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
        deleteButton.tintColor = .slPurple
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }

    @objc
    private func deleteAction() {
        textDocumentProxy.deleteBackward()
    }
}
