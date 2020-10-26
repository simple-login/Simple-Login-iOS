//
//  WhatYouCanDoViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 05/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class WhatYouCanDoViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        WhatTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDataSource
extension WhatYouCanDoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        What.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = WhatTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: What.allCases[indexPath.row])
        return cell
    }
}
