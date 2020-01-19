//
//  CustomDomainViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class CustomDomainViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("CustomDomainViewController is deallocated")
    }
    
    private lazy var customDomains: [CustomDomain] = {
        var customDomains: [CustomDomain] = []
        
        for _ in 0...10 {
            customDomains.append(CustomDomain())
        }
        
        return customDomains
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        CustomDomainTableViewCell.register(with: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let customDomainDetailViewController as CustomDomainDetailViewController:
            guard let customDomain = sender as? CustomDomain else { return }
            customDomainDetailViewController.customDomain = customDomain
        
        default: return
        }
    }
}

// MARK: - UITableViewDelegate
extension CustomDomainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let customDomain = customDomains[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: customDomain)
    }
}

// MARK: - UITableViewDataSource
extension CustomDomainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customDomains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomDomainTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let customDomain = customDomains[indexPath.row]
        cell.bind(with: customDomain)
        return cell
    }
}
