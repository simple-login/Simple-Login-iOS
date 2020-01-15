//
//  BaseTableViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 15/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    var didTapLeftBarButtonItem: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButtonItem()
    }
    
    private func addLeftBarButtonItem() {
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .plain, target: self, action: #selector(tappedLeftBarButtonItem))
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @objc private func tappedLeftBarButtonItem() {
        didTapLeftBarButtonItem?()
    }
}
