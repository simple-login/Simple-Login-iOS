//
//  DeletedAliasesViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import UIKit

final class DeletedAliasesViewController: BaseApiKeyViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    private let refreshControl = UIRefreshControl()

    private lazy var deletedAliases: [DeletedAlias] = {
        var deletedAliases: [DeletedAlias] = []

        for _ in 0...10 {
            deletedAliases.append(DeletedAlias())
        }

        return deletedAliases
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchDeletedAliases()
    }

    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear

        DeletedAliasTableViewCell.register(with: tableView)

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc
    private func refresh() {
        fetchDeletedAliases()
    }

    private func fetchDeletedAliases() {
    }
}

// MARK: - UITableViewDataSource
extension DeletedAliasesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deletedAliases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DeletedAliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: deletedAliases[indexPath.row])
        return cell
    }
}
