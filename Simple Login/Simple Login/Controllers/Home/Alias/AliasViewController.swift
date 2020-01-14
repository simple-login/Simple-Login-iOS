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
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private enum AliasType {
        case all, active, inactive
    }
    
    private lazy var aliases: [Alias] = {
        var aliases: [Alias] = []
        for _ in 0...30 {
            aliases.append(Alias())
        }
        
        return aliases
    }()
    
    private var activeAliases: [Alias] = []
    private var inactiveAliases: [Alias] = []
    
    private var currentAliasType: AliasType = .all {
        didSet {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    deinit {
        print("AliasViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        refilterAliasArrays()
    }
    
    private func setUpUI() {
        view.backgroundColor = SLColor.backBackgroundColor
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        AliasTableViewCell.register(with: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let sendEmailViewController as SendEmailViewController:
            guard let alias = sender as? Alias else { return }
            sendEmailViewController.alias = alias
            
        case let aliasActivityViewController as AliasActivityViewController:
            guard let alias = sender as? Alias else { return }
            aliasActivityViewController.alias = alias
            
        default: return
        }
    }
    
    private func presentAlertConfirmDelete(alias: Alias) {
        let alert = UIAlertController(title: "Delete \(alias.name)", message: "🛑 People/apps who used to contact you via this alias cannot reach you any more. This operation is irreversible", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            Toast.displayShortly(message: "Deleted")
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - SegmentedControl actions
extension AliasViewController {
    @IBAction private func segmentedControlValueChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentAliasType = .all
        case 1: currentAliasType = .active
        case 2: currentAliasType = .inactive
        default: return
        }
    }
    
    private func refilterAliasArrays() {
        activeAliases.removeAll()
        activeAliases.append(contentsOf: aliases.filter({$0.isEnabled == true}))
        
        inactiveAliases.removeAll()
        inactiveAliases.append(contentsOf: aliases.filter({$0.isEnabled == false}))
    }
}

// MARK: - Button actions
extension AliasViewController {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }
        
        performSegue(withIdentifier: "showAliasActivity", sender: alias)
    }
}

// MARK: - UITableViewDataSource
extension AliasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentAliasType {
        case .all: return aliases.count
        case .active: return activeAliases.count
        case .inactive: return inactiveAliases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }
        
        cell.bind(with: alias)
        
        cell.didToggleStatus = { [unowned self] isEnabled in
            Toast.displayShortly(message: "is_enabled: \(isEnabled)")
        }
        
        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showSendEmail", sender: alias)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            self.presentAlertConfirmDelete(alias: alias)
        }
        
        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showAliasActivity", sender: alias)
        }
        
        return cell
    }
}

