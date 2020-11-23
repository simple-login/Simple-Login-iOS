//
//  DomainLiteListViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 23/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DomainLiteListViewController: BaseViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    var domains: [DomainLite]!
    var currentDefaultDomainName: String!

    var didSelectDomain: ((_ domain: DomainLite) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(domains != nil, "List of domain (DomainLite) must be set for \(Self.self)")
        assert(currentDefaultDomainName != nil, "Current default domain name must be set for \(Self.self)")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension DomainLiteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectDomain?(domains[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension DomainLiteListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        domains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let domain = domains[indexPath.row]
        cell.textLabel?.text = domain.name
        cell.detailTextLabel?.text = domain.isCustom ? "Your domain" : "SimpleLogin domain"
        cell.detailTextLabel?.textColor = domain.isCustom ? SLColor.tintColor : .darkGray
        cell.accessoryType = domain.name == currentDefaultDomainName ? .checkmark : .none
        return cell
    }
}
