//
//  HowItWorksViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class HowItWorksViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("HowItWorksViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        StepTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDataSource
extension HowItWorksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Step.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = StepTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let step = Step.allCases[indexPath.row]
        cell.bind(with: step)
        return cell
    }
}
