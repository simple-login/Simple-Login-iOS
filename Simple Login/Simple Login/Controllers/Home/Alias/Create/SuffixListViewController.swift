//
//  SuffixListViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

protocol SuffixListViewControllerDelegate: class {
    func didSelectSuffix(atIndex index: Int)
}

final class SuffixListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    var selectedSuffixIndex: Int!
    var suffixes: [Suffix]!
    weak var delegate: SuffixListViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension SuffixListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectSuffix(atIndex: indexPath.row)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SuffixListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suffixes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let suffix = suffixes[indexPath.row]
        cell.textLabel?.text = suffix.value[0]

        if indexPath.row == selectedSuffixIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}
