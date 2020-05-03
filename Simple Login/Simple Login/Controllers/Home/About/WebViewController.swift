//
//  WebViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 15/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    
    enum Module {
        case team, pricing, blog, terms, privacy, security
        
        var urlString: String {
            switch self {
            case .team: return "\(BASE_WEBSITE_URL)/about"
            case .pricing: return "\(BASE_WEBSITE_URL)/pricing"
            case .blog: return "\(BASE_WEBSITE_URL)/blog"
            case .terms: return "\(BASE_WEBSITE_URL)/terms"
            case .privacy: return "\(BASE_WEBSITE_URL)/privacy"
            case .security: return "\(BASE_WEBSITE_URL)/security"
            }
        }
    }
    
    var module: Module!
    
    deinit {
        print("WebViewController is deallocated")
    }
    
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
