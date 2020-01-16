//
//  SendEmailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI
import Toaster

final class SendEmailViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var alias: Alias!
    
    private lazy var reverseAliases: [ReverseAlias] = {
        var reverseAliases: [ReverseAlias] = []
        for _ in 0...30 {
            reverseAliases.append(ReverseAlias())
        }
        
        return reverseAliases
    }()
    
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
        ReverseAliasTableViewCell.register(with: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let createReverseAliasViewController as CreateReverseAliasViewController:
            createReverseAliasViewController.alias = alias
            
        default: return
        }
    }
    
    private func presentAlertWriteEmail(_ reverseAlias: ReverseAlias) {
        let alert = UIAlertController(title: "Compose and send email", message: "From \(alias.name) to \(reverseAlias.destinationEmail)", preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copy reverse-alias", style: .default) { (_) in
            UIPasteboard.general.string = reverseAlias.name
            Toast.displayShortly(message: "Copied \(reverseAlias.name)")
        }
        alert.addAction(copyAction)
        
        let openEmaiAction = UIAlertAction(title: "Begin composing with default email", style: .default) { (_) in
            let mailComposerVC = MFMailComposeViewController()
            
            guard let _ = mailComposerVC.view else {
                return
            }
            
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([reverseAlias.name])
            
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        alert.addAction(openEmaiAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentAlertConfirmDelete(reverseAlias: ReverseAlias) {
        let alert = UIAlertController(title: "Delete \(reverseAlias.name)", message: "🛑 This operation is irreversible", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            Toast.displayShortly(message: "Deleted")
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension SendEmailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alias.name
    }
}

// MARK: - UITableViewDataSource
extension SendEmailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reverseAliases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReverseAliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let reverseAlias = reverseAliases[indexPath.row]
        cell.bind(with: reverseAlias)
        
        cell.didTapWriteEmailButton = { [unowned self] in
            self.presentAlertWriteEmail(reverseAlias)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            self.presentAlertConfirmDelete(reverseAlias: reverseAlias)
        }
        
        return cell
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SendEmailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
