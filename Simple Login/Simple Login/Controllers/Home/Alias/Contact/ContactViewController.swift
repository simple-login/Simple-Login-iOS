//
//  ContactViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI
import Toaster

final class ContactViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var alias: Alias!
    
    private var contacts: [Contact] = [] {
        didSet {
            noContact = contacts.count == 0
        }
    }
    
    private var noContact: Bool = false {
        didSet {
            tableView.isHidden = noContact
        }
    }
    
    private var fetchedPage: Int = -1
    private var isFetching: Bool = false
    private var moreToLoad: Bool = true
    
    deinit {
        print("ContactViewController is deallocated")
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
        
        ContactTableViewCell.register(with: tableView)
        tableView.register(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        fetchContacts()
    }
    
    private func fetchContacts() {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        if refreshControl.isRefreshing {
            moreToLoad = true
        }
        
        guard moreToLoad, !isFetching else { return }
        
        isFetching = true
        
        let pageToFetch = refreshControl.isRefreshing ? 0 : fetchedPage + 1
        
        SLApiService.fetchContacts(apiKey: apiKey, aliasId: alias.id, page: pageToFetch) { [weak self] (contacts, error) in
            guard let self = self else { return }
            
            self.isFetching = false
            
            if let contacts = contacts {
                
                if contacts.count == 0 {
                    self.moreToLoad = false
                } else {
                    if self.refreshControl.isRefreshing {
                        print("Refreshed & fetched \(contacts.count) contacts")
                    } else {
                        print("Fetched page \(self.fetchedPage + 1) - \(contacts.count) contacts")
                    }
                    
                    if self.refreshControl.isRefreshing {
                        self.fetchedPage = 0
                        self.contacts.removeAll()
                    } else {
                        self.fetchedPage += 1
                    }
                    
                    self.contacts.append(contentsOf: contacts)
                }
                
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            } else if let error = error {
                self.refreshControl.endRefreshing()
                Toast.displayError(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let createContactViewController as CreateContactViewController:
            createContactViewController.alias = alias
            
        default: return
        }
    }
    
    private func presentAlertWriteEmail(_ contact: Contact) {
        let alert = UIAlertController(title: "Compose and send email", message: "From \(alias.email) to \(contact.email)", preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copy reverse-alias", style: .default) { (_) in
            UIPasteboard.general.string = contact.reverseAlias
            Toast.displayShortly(message: "Copied \(contact.reverseAlias)")
        }
        alert.addAction(copyAction)
        
        let openEmaiAction = UIAlertAction(title: "Begin composing with default email", style: .default) { (_) in
            let mailComposerVC = MFMailComposeViewController()
            
            guard let _ = mailComposerVC.view else {
                return
            }
            
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([contact.email])
            
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        alert.addAction(openEmaiAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentAlertConfirmDelete(_ contact: Contact) {
        let alert = UIAlertController(title: "Delete \(contact.email)", message: "🛑 This operation is irreversible", preferredStyle: .alert)
        
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
extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alias.email
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return moreToLoad ? 44.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if moreToLoad {
            let loadingFooterView =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "LoadingFooterView") as? LoadingFooterView
            loadingFooterView?.animate()
            return loadingFooterView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if moreToLoad {
            fetchContacts()
        }
    }
}

// MARK: - UITableViewDataSource
extension ContactViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContactTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let contact = contacts[indexPath.row]
        cell.bind(with: contact)
        
        cell.didTapWriteEmailButton = { [unowned self] in
            self.presentAlertWriteEmail(contact)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            self.presentAlertConfirmDelete(contact)
        }
        
        return cell
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ContactViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
