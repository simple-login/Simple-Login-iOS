//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Thanh-Nhon Nguyen on 08/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Social
import MBProgressHUD

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractUrlString()
    }
    
    private func extractUrlString() {
        MBProgressHUD.showAdded(to: view, animated: true)
        extensionContext?.inputItems.forEach({ [unowned self] (item) in
            if let extensionItem = item as? NSExtensionItem, let attachments = extensionItem.attachments {
                for itemProvider in attachments {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (object, error) in
                        if let url = object as? URL {
                            self.fetchUserOptions(url: url)
                        }
                    }
                }
            }
        })
    }
    
    private func fetchUserOptions(url: URL) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            MBProgressHUD.hide(for: view, animated: true)
            return
        }
        
        SLApiService.fetchUserOptions(apiKey: apiKey, hostname: url.host ?? "") { [weak self] (userOptions, error) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            print(userOptions)
        }
    }
}
