//
//  MailboxViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit
import Toaster

final class MailboxViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var mailboxes: [Mailbox] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchMailboxes()
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        MailboxTableViewCell.register(with: tableView)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchMailboxes), for: .valueChanged)
    }
    
    @objc private func fetchMailboxes() {
        SLApiService.fetchMailboxes(apiKey: apiKey) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let mailboxes):
                self.mailboxes = mailboxes
                self.tableView.reloadData()
                
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                    Toast.displayUpToDate()
                }
                
            case .failure(let error):
                self.refreshControl.endRefreshing()
                Toast.displayError(error)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension MailboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MailboxViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MailboxTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let mailbox = mailboxes[indexPath.row]
        cell.bind(with: mailbox)
        return cell
    }
}
