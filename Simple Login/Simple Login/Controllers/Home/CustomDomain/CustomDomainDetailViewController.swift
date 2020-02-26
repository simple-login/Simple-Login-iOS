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
        DeleteDomainTableViewCell.register(with: tableView)
    }
    
    private func showConfirmDeletionAlert() {
        let alert = UIAlertController(title: "Please confirm", message: "You are about to delete domain \"\(customDomain.name)\" from SimpleLogin", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Yes, delete this domain", style: .destructive) { [unowned self] (_) in
            self.deleteDomain()
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteDomain() {
        
    }
}

// MARK: - UITableViewDataSource
extension CustomDomainDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
                if let url = URL(string: "\(BASE_URL)/dashboard/domains/\(self.customDomain.id)/dns") {
                    UIApplication.shared.open(url)
                }
            }
            
            return cell
        case 2:
            let cell = DeleteDomainTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapDeleteButton = { [unowned self] in
                self.showConfirmDeletionAlert()
            }
            
            return cell
            
        default: return UITableViewCell()
        }
    }
}
