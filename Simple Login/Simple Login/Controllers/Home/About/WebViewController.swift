//
//  WebViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 15/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: BaseViewController {
    @IBOutlet private weak var webView: WKWebView!

    private static let baseWebsiteUrl = "https://simplelogin.io"

    enum Module {
        case team, pricing, blog, terms, privacy, security, help

        var urlString: String {
            switch self {
            case .team: return "\(baseWebsiteUrl)/about"
            case .pricing: return "\(baseWebsiteUrl)/pricing"
            case .blog: return "\(baseWebsiteUrl)/blog"
            case .terms: return "\(baseWebsiteUrl)/terms"
            case .privacy: return "\(baseWebsiteUrl)/privacy"
            case .security: return "\(baseWebsiteUrl)/security"
            case .help: return "\(baseWebsiteUrl)/help"
            }
        }
    }

    var module: Module!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let url = URL(string: module.urlString) {
            webView.load(URLRequest(url: url))
            webView.navigationDelegate = self
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
