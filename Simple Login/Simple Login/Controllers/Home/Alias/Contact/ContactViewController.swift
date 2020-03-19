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
import MBProgressHUD
import FirebaseAnalytics

final class ContactViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var alias: Alias!
    
    private var contacts: [Contact] = []
    
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
        fetchContacts()
        Analytics.logEvent("open_contact_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        ContactTableViewCell.register(with: tableView)
        tableView.register(UINib(nibName: "ContactTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ContactTableHeaderView")
        tableView.register(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        fetchContacts()
        Analytics.logEvent("contact_list_refresh", parameters: nil)
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
                        self.fetchedPage = 0
                        self.contacts.removeAll()
                    } else {
                        self.fetchedPage += 1
                    }
                    
                    self.contacts.append(contentsOf: contacts)
                }
                
                self.noContact = self.contacts.count == 0
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            } else if let error = error {
                self.refreshControl.endRefreshing()
                Toast.displayError(error)
                Analytics.logEvent("contact_list_error_fetching", parameters: ["error": error.description])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let createContactViewController as CreateContactViewController:
            createContactViewController.alias = alias
            createContactViewController.didCreateContact = { [unowned self] in
                self.refreshControl.beginRefreshing()
                self.refresh()
            }
            
        default: return
        }
    }
    
    private func presentAlertWriteEmail(_ contact: Contact) {
        let alert = UIAlertController(title: "Compose and send email", message: "From: \"\(alias.email)\"\nTo: \"\(contact.email)\"", preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copy reverse-alias", style: .default) { (_) in
            UIPasteboard.general.string = contact.reverseAlias
            Toast.displayShortly(message: "Copied \"\(contact.reverseAlias)\"")
            Analytics.logEvent("contact_list_copied_a_contact", parameters: nil)
        }
        alert.addAction(copyAction)
        
        let openEmaiAction = UIAlertAction(title: "Begin composing with default email", style: .default) { (_) in
            let mailComposerVC = MFMailComposeViewController()
            
            guard let _ = mailComposerVC.view else {
                return
            }
            
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([contact.reverseAlias])
            
            self.present(mailComposerVC, animated: true, completion: nil)
            Analytics.logEvent("contact_list_write_to_a_contact", parameters: nil)
        }
        alert.addAction(openEmaiAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentAlertConfirmDelete(_ contact: Contact, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete \(contact.email)", message: "🛑 This operation is irreversible", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.delete(contact: contact, indexPath: indexPath)
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func delete(contact: Contact, indexPath: IndexPath) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.deleteContact(apiKey: apiKey, id: contact.id) { [weak self] (error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("contact_list_delete_error", parameters: ["error": error.description])
                
            } else {
                self.tableView.performBatchUpdates({
                    self.contacts.removeAll { $0.id == contact.id }
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }) { _ in
                    self.tableView.reloadData()
                    Toast.displayShortly(message: "Deleted contact \"\(contact.email)\"")
                    Analytics.logEvent("contact_list_deleted_a_contact", parameters: nil)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contactTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContactTableHeaderView") as? ContactTableHeaderView
        contactTableHeaderView?.bind(with: alias.email)
        return contactTableHeaderView
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
            Analytics.logEvent("contact_list_fetch_more", parameters: nil)
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
            self.presentAlertConfirmDelete(contact, indexPath: indexPath)
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
