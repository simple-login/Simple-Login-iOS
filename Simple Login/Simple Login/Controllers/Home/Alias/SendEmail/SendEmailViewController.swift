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
    }
    
    @IBAction private func hintButtonTapped() {
        
    }
    
    @IBAction private func addButtonTapped() {
        
    }
}

// MARK: - UITableViewDelegate
extension SendEmailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SendEmailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
