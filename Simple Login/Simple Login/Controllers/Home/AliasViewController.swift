//
//  AliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var aliases: [Alias] = {
        var aliases: [Alias] = []
        for _ in 0...30 {
            aliases.append(Alias())
        }
        
        return aliases
    }()
    
    deinit {
        print("AliasViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        AliasTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDelegate
extension AliasViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension AliasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aliases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: aliases[indexPath.row])
        return cell
    }
}

