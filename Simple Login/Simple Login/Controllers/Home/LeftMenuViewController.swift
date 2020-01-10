//
//  LeftMenuViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class LeftMenuViewController: UIViewController {
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    private let options: [[LeftMenuOption]] = [[.alias, .aliasDirectory, .customDomains], [.separator],  [.settings, .about]]
    
    var userInfo: UserInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindUserInfo()
    }

    private func setUpUI() {
        // avatarImageView
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = avatarImageView.tintColor.cgColor
        avatarImageView.layer.backgroundColor = avatarImageView.tintColor.withAlphaComponent(0.5).cgColor
        
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        LeftMenuOptionTableViewCell.register(with: tableView)
        SeparatorTableViewCell.register(with: tableView)
    }
    
    private func bindUserInfo() {
        guard let userInfo = userInfo else {
            usernameLabel.text = nil
            statusLabel.text = nil
            return
        }
        
        usernameLabel.text = userInfo.name
        
        if userInfo.isPremium {
            statusLabel.text = "Premium"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Upgrade"
            statusLabel.textColor = .darkGray
        }
    }
}

// MARK: - UITableViewDataSource
extension LeftMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let option = options[indexPath.section][indexPath.row]
        
        if option != .separator {
            return UITableView.automaticDimension
        }
        
        return 1 // separator cell
    }
}

// MARK: - UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.section][indexPath.row]
        
        if option != .separator {
            let cell = LeftMenuOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.bind(with: option)
            return cell
        }
        
        return SeparatorTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
    }
}
