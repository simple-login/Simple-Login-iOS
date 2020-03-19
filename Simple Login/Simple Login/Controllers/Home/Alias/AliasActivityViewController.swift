//
//  AliasActivityViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MarqueeLabel
import MBProgressHUD
import FirebaseAnalytics

final class AliasActivityViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var alias: Alias!
    
    var didUpdateNote: (() -> Void)?
    
    private var activities: [AliasActivity] = []
    
    private var fetchedPage: Int = -1
    private var isFetching: Bool = false
    private var moreToLoad: Bool = true
    
    deinit {
        print("AliasActivityViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchActivities()
        Analytics.logEvent("open_alias_activity_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        // set up title
        let titleLabel = MarqueeLabel(frame: .zero, duration: 1.0, fadeLength: 8.0)
        titleLabel.type = .leftRight
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = SLColor.textColor
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.text = alias.email
        navigationItem.titleView = titleLabel
        
        // tableView
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        tableView.register(UINib(nibName: "AliasActivityTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AliasActivityTableHeaderView")
        tableView.register(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        AliasActivityTableViewCell.register(with: tableView)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        fetchActivities()
        Analytics.logEvent("alias_activity_refresh", parameters: nil)
    }
    
    private func fetchActivities() {
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
        
        SLApiService.fetchAliasActivities(apiKey: apiKey, aliasId: alias.id, page: pageToFetch) { [weak self] (activities, error) in
            guard let self = self else { return }
            
            self.isFetching = false
            
            if let activities = activities {
                
                if activities.count == 0 {
                    self.moreToLoad = false
                } else {
                    if self.refreshControl.isRefreshing {
                        self.fetchedPage = 0
                        self.activities.removeAll()
                    } else {
                        self.fetchedPage += 1
                    }
                    
                    self.activities.append(contentsOf: activities)
                }
                
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            } else if let error = error {
                self.refreshControl.endRefreshing()
                Toast.displayError(error)
                Analytics.logEvent("alias_activity_error_fetching", parameters: ["error": error.description])
            }
            
        }
    }
}

// MARK: - Edit notes
extension AliasActivityViewController {
    private func presentAlertEditNotes() {
        let title: String
        if let note = alias.note, note != "" {
            title = "Edit note for alias"
        } else {
            title = "Add note for alias"
        }
        
        let alert = UIAlertController(title: title, message: alias.email, preferredStyle: .alert)
        
        let textView = alert.addTextView(initialText: alias.note)
        
        let updateAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            self.updateNote(textView.text)
        }
        alert.addAction(updateAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            textView.becomeFirstResponder()
        }
    }
    
    private func updateNote(_ note: String?) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.updateAliasNote(apiKey: apiKey, id: alias.id, note: note) { [weak self] error in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("alias_activity_edit_note_error", parameters: ["error": error.description])
                
            } else {
                self.alias.setNote(note)
                self.tableView.reloadData()
                self.didUpdateNote?()
                Analytics.logEvent("alias_activity_edit_note_success", parameters: nil)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension AliasActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AliasActivityTableHeaderView") as? AliasActivityTableHeaderView
        header?.bind(with: alias)
        
        header?.didTapEditButton = { [unowned self] in
            self.presentAlertEditNotes()
        }
        
        return header
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
            fetchActivities()
            Analytics.logEvent("alias_activity_fetch_more", parameters: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension AliasActivityViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AliasActivityTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: activities[indexPath.row])
        return cell
    }
}
