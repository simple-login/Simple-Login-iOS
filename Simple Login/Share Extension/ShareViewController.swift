//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Thanh-Nhon Nguyen on 08/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Social

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractUrlString()
        print(SLKeychainService.getApiKey())
    }
    
    private func extractUrlString() {
        extensionContext?.inputItems.forEach({ (item) in
            if let extensionItem = item as? NSExtensionItem, let attachments = extensionItem.attachments {
                for itemProvider in attachments {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (object, error) in
                        if let url = object as? NSURL {
                            print(url.absoluteString)
                        }
                    }
                }
            }
        })
    }
}
