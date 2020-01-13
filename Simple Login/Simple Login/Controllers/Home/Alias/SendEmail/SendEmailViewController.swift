//
//  SendEmailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class SendEmailViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var alias: Alias!
    
    private lazy var reverseAliases: [ReverseAlias] = {
        var reverseAliases: [ReverseAlias] = []
        for _ in 0...30 {
            reverseAliases.append(ReverseAlias())
        }
        
        return reverseAliases
    }()
    
    deinit {
        print("SendEmailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        ReverseAliasTableViewCell.register(with: tableView)
    }
    
    @IBAction private func addButtonTapped() {
        
    }
}

// MARK: - UITableViewDelegate
extension SendEmailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alias.name
    }
}

// MARK: - UITableViewDataSource
extension SendEmailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reverseAliases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReverseAliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let reverseAlias = reverseAliases[indexPath.row]
        cell.bind(with: reverseAlias)
        return cell
    }
}
