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

final class AliasActivityViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var alias: Alias!
    
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
                        print("Refreshed & fetched \(activities.count) activities")
                    } else {
                        print("Fetched page \(self.fetchedPage + 1) - \(activities.count) activities")
                    }
                    
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
            }
            
        }
    }
}

// MARK: - UITableViewDelegate
extension AliasActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AliasActivityTableHeaderView") as? AliasActivityTableHeaderView
        header?.bind(with: alias)
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
