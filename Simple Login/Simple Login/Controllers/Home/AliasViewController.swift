//
//  AliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

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

// MARK: - Button actions
extension AliasViewController {
    @IBAction private func addButtonTapped() {
//        let alert = UIAlertController(title: "New email alias", message: "To make it easy to remember for later use, it is a good practice to use the name of the website that you plan to register with alias.", preferredStyle: .alert)
    }
    
    private func displayCreateAliasAlert(suggestion: String) {
        
    }
    
    @IBAction private func shuffleButtonTapped() {
        let alert = UIAlertController(title: "New email alias", message: "Randomly create an alias", preferredStyle: .actionSheet)
        
        let byWordAction = UIAlertAction(title: "By random words", style: .default) { [unowned self] (_) in
            self.randomByWords()
        }
        alert.addAction(byWordAction)
        
        let byUUIDAction = UIAlertAction(title: "By UUID", style: .default) { [unowned self] (_) in
            self.randomByUUID()
        }
        alert.addAction(byUUIDAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func randomByWords() {
        Toast.displayShortly(message: #function)
    }
    
    private func randomByUUID() {
        Toast.displayShortly(message: #function)
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

