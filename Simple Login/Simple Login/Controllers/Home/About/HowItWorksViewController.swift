//
//  HowItWorksViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class HowItWorksViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var hows: [How] = []
    
    deinit {
        print("HowItWorksViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        initHows()
        Analytics.logEvent("open_how_it_works_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        FaqTableViewCell.register(with: tableView)
    }
    
    private func initHows() {
        let how1 = How(title: "1. Sign up and start creating aliases", description: "The next time a website asks for your email address, just create a new alias instead of using your real email.")
        let how2 = How(title: "2. Receive emails safely", description: "All emails sent to an alias are forwarded to your \"real\" email address without the sender knowing anything.")
        let how3 = How(title: "3. Create aliases without leaving the browser", description: "On your desktop, you can install our browser extension to manage and quickly create aliases on the fly.\n\nOn your smartphone with SimpleLogin installed, whenever you need to register to a website, simply \"share\" the website you are visiting with SimpleLogin to quickly create an alias.")
        hows.append(contentsOf: [how1, how2, how3])
    }
}

// MARK: - UITableViewDataSource
extension HowItWorksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: hows[indexPath.row])
        return cell
    }
}
