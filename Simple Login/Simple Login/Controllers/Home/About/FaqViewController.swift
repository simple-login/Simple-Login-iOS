//
//  FaqViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class FaqViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("FaqViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        Analytics.logEvent("open_faq_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        FaqTableViewCell.register(with: tableView)
    }
}

// MARK: - FaqViewController
extension FaqViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Faq.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let faq = Faq.allCases[indexPath.row]
        cell.bind(with: faq)
        return cell
    }
}
