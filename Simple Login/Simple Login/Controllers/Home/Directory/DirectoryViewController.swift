//
//  DirectoryViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DirectoryViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private var noDirectory: Bool = false {
        didSet {
            tableView.isHidden = noDirectory
        }
    }
    
    private lazy var directories: [Directory] = {
        var directories: [Directory] = []
        
        for _ in 0...10 {
            directories.append(Directory())
        }
        
        return directories
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchDirectories()
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        
        DirectoryTableViewCell.register(with: tableView)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        fetchDirectories()
    }
    
    private func fetchDirectories() {
        
    }
    
    @IBAction private func addButtonTapped() {
        let alert = UIAlertController(title: "Create directory", message: "Pick an epic name for your directory", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned self] (_) in
            if let directoryName = alert.textFields?[0].text {
                self.createDirectory(name: directoryName)
            }
        }
        alert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func createDirectory(name: String) {
        print("create \(name)")
    }
    
    private func showConfirmDeletionAlert(directory: Directory) {
        let alert = UIAlertController(title: "Please confirm", message: "All aliases associated with \"\(directory.name)\" directory will be also deleted", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Yes, delete this directory", style: .destructive) { [unowned self] (_) in
            self.delete(directory: directory)
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func delete(directory: Directory) {
        print("delete \(directory.name)")
    }
}

// MARK: - UITableViewDataSource
extension DirectoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DirectoryTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        let directory = directories[indexPath.row]
        
        cell.didTapDelete = { [unowned self] in
            self.showConfirmDeletionAlert(directory: directory)
        }
        
        cell.bind(with: directory)
        
        return cell
    }
}
