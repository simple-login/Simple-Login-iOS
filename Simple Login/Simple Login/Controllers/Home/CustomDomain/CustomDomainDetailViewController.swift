//
//  CustomDomainDetailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class CustomDomainDetailViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var customDomain: CustomDomain!
    
    deinit {
        print("CustomDomainDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        title = customDomain.name
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        
        DomainInfoTableViewCell.register(with: tableView)
        NotVerifiedDomainTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDataSource
extension CustomDomainDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = DomainInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.bind(with: customDomain)
            return cell
            
        case 1:
            let cell = NotVerifiedDomainTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapVerifyButton = { [unowned self] in
                print("verify")
            }
            
            return cell
            
        default: return UITableViewCell()
        }
    }
}
