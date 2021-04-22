//
//  AliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Differ
import MBProgressHUD
import Toaster
import UIKit

final class AliasViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    private let refreshControl = UIRefreshControl()

    private enum AliasType {
        case all, active, inactive
    }

    private var aliases: [Alias] = []

    private var activeAliases: [Alias] = []
    private var inactiveAliases: [Alias] = []

    private var fetchedPage = -1
    private var isFetching = false
    private var moreToLoad = true

    private var currentAliasType: AliasType = .all {
        didSet {
            switch (oldValue, currentAliasType) {
            case (.all, .active):
                tableView.animateRowChanges(oldData: aliases, newData: activeAliases)

            case (.all, .inactive):
                tableView.animateRowChanges(oldData: aliases, newData: inactiveAliases)

            case (.active, .all):
                tableView.animateRowChanges(oldData: activeAliases, newData: aliases)

            case (.active, .inactive):
                tableView.animateRowChanges(oldData: activeAliases, newData: inactiveAliases)

            case (.inactive, .all):
                tableView.animateRowChanges(oldData: inactiveAliases, newData: aliases)

            case (.inactive, .active):
                tableView.animateRowChanges(oldData: inactiveAliases, newData: activeAliases)

            default: break
            }

            var scrollToTop = false
            switch currentAliasType {
            case .all: scrollToTop = !aliases.isEmpty
            case .active: scrollToTop = !activeAliases.isEmpty
            case .inactive: scrollToTop = !inactiveAliases.isEmpty
            }

            if scrollToTop {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    private var noAlias = false {
        didSet {
            tableView.isHidden = noAlias
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchAliases()
    }

    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear

        AliasTableViewCell.register(with: tableView)
        tableView.register(
            UINib(nibName: "LoadingFooterView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "LoadingFooterView")

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sendEmailViewController as ContactViewController:
            guard let alias = sender as? Alias else { return }
            sendEmailViewController.alias = alias

        case let aliasActivityViewController as AliasActivityViewController:
            guard let alias = sender as? Alias else { return }
            aliasActivityViewController.alias = alias

            aliasActivityViewController.didUpdateAlias = { [unowned self] updatedAlias in
                self.updateAlias(updatedAlias)
            }

        case let createAliasViewController as CreateAliasViewController:
            Vibration.rigid.vibrate()
            createAliasViewController.showPremiumFeatures = { [unowned self] in
                let iapViewController = IapViewController.instantiate(storyboardName: "Settings")
                self.navigationController?.pushViewController(iapViewController, animated: true)
            }

            createAliasViewController.createdAlias = { [unowned self] alias in
                self.finalizeAliasCreation(alias)
            }

            createAliasViewController.didDisappear = { [unowned self] in
                if !Settings.shared.showedDeleteAndRandomAliasInstruction {
                    self.performSegue(withIdentifier: "showInstruction", sender: nil)
                }
            }

        case let aliasSearchNavigationController as AliasSearchNavigationController:
            Vibration.soft.vibrate()
            // swiftlint:disable:next line_length
            guard let aliasSearchViewController = aliasSearchNavigationController.viewControllers[0] as? AliasSearchViewController else { return }

            aliasSearchViewController.toggledAlias = { [unowned self] alias in
                for eachAlias in self.aliases where eachAlias == alias {
                    eachAlias.setEnabled(alias.enabled)
                    self.refilterAliasArrays()
                    self.tableView.reloadData()
                }
            }

            aliasSearchViewController.deletedAlias = { [unowned self] alias in
                self.aliases.removeAll(where: { $0 == alias })
                self.refilterAliasArrays()
                self.tableView.reloadData()
            }

        default: return
        }
    }

    @objc
    private func refresh() {
        fetchAliases()
    }

    private func fetchAliases() {
        if refreshControl.isRefreshing {
            moreToLoad = true
        }

        guard moreToLoad, !isFetching else { return }

        isFetching = true

        let pageToFetch = refreshControl.isRefreshing ? 0 : fetchedPage + 1

        SLClient.shared.fetchAliases(apiKey: apiKey, page: pageToFetch) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isFetching = false

                switch result {
                case .success(let aliasArray):
                    if aliasArray.aliases.isEmpty {
                        self.moreToLoad = false
                    } else {
                        if self.refreshControl.isRefreshing {
                            self.fetchedPage = 0
                            self.aliases.removeAll()
                        } else {
                            self.fetchedPage += 1
                        }

                        // Remove duplicated aliases before appending to current array
                        let aliasesToAppend = aliasArray.aliases.filter { !self.aliases.contains($0) }

                        self.aliases.append(contentsOf: aliasesToAppend)
                        self.refilterAliasArrays()
                    }

                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                        Toast.displayUpToDate()
                    }

                    self.noAlias = self.isEditing
                    self.tableView.reloadData()

                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    Toast.displayError(error)
                }
            }
        }
    }

    private func finalizeAliasCreation(_ alias: Alias) {
        switch currentAliasType {
        case .all, .active:
            let firstIndexPath = IndexPath(row: 0, section: 0)
            noAlias = false

            tableView.performBatchUpdates({
                self.aliases.insert(alias, at: 0)
                self.refilterAliasArrays()
                self.tableView.insertRows(at: [firstIndexPath], with: .automatic)
            }, completion: { _ in
                self.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            })

        case .inactive:
            self.aliases.insert(alias, at: 0)
            self.refilterAliasArrays()
        }

        Toast.displayShortly(message: "Created \(alias.email)")
    }

    private func updateAlias(_ updatedAlias: Alias) {
        if let index = aliases.firstIndex(where: { $0.id == updatedAlias.id }) {
            aliases[index] = updatedAlias
            refilterAliasArrays()
            tableView.reloadData()
        }
    }
}

// MARK: - Toggle status
extension AliasViewController {
    private func toggle(alias: Alias, at indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.toggleAlias(apiKey: apiKey, aliasId: alias.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success(let enabled):
                    alias.setEnabled(enabled.value)

                    self.tableView.performBatchUpdates({
                        switch self.currentAliasType {
                        case .all: return

                        case .active:
                            self.activeAliases.removeAll(where: { $0 == alias })
                            self.tableView.deleteRows(at: [indexPath], with: .fade)

                        case .inactive:
                            self.inactiveAliases.removeAll(where: { $0 == alias })
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }, completion: { _ in
                        self.refilterAliasArrays()
                        self.tableView.reloadData()
                    })

                case .failure(let error):
                    Toast.displayError(error)
                    // reload data to switch alias to initial state when request to server fails
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Delete
extension AliasViewController {
    private func presentAlertConfirmDelete(alias: Alias, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete \"\(alias.email)\"?",
            // swiftlint:disable:next line_length
            message: "🛑 People/apps who used to contact you via this alias cannot reach you any more. This operation is irreversible. Please confirm.",
            preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.delete(alias: alias, at: indexPath)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func delete(alias: Alias, at indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.deleteAlias(apiKey: apiKey, aliasId: alias.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success:
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: [indexPath], with: .fade)

                        switch self.currentAliasType {
                        case .all:
                            self.aliases.removeAll(where: { $0 == alias })
                            self.refilterAliasArrays()

                        case .active:
                            self.activeAliases.removeAll(where: { $0 == alias })
                            self.aliases.removeAll(where: { $0 == alias })

                        case .inactive:
                            self.inactiveAliases.removeAll(where: { $0 == alias })
                            self.aliases.removeAll(where: { $0 == alias })
                        }
                    }, completion: { _ in
                        self.tableView.reloadData()
                        self.noAlias = self.aliases.isEmpty
                        Toast.displayShortly(message: "Deleted alias \"\(alias.email)\"")
                    })

                case .failure(let error): Toast.displayError(error)
                }
            }
        }
    }
}

// MARK: - SegmentedControl actions
extension AliasViewController {
    @IBAction private func segmentedControlValueChanged() {
        Vibration.selection.vibrate()
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentAliasType = .all
        case 1: currentAliasType = .active
        case 2: currentAliasType = .inactive
        default: return
        }
    }

    private func refilterAliasArrays() {
        activeAliases.removeAll()
        activeAliases.append(contentsOf: aliases.filter { $0.enabled == true })

        inactiveAliases.removeAll()
        inactiveAliases.append(contentsOf: aliases.filter { $0.enabled == false })
    }
}

// MARK: - Random alias
extension AliasViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            presentRandomAliasAlert()
        }
    }

    private func presentRandomAliasAlert() {
        let alert = UIAlertController(title: "New email alias",
                                      message: "Randomly create an alias",
                                      preferredStyle: .actionSheet)

        let byWordAction = UIAlertAction(title: "By random words", style: .default) { [unowned self] _ in
            self.randomAlias(mode: .word)
        }
        alert.addAction(byWordAction)

        let byUUIDAction = UIAlertAction(title: "By UUID", style: .default) { [unowned self] _ in
            self.randomAlias(mode: .uuid)
        }
        alert.addAction(byUUIDAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func randomAlias(mode: RandomMode) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.randomAlias(apiKey: apiKey, randomMode: mode) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success(let newlyCreatedAlias): self.finalizeAliasCreation(newlyCreatedAlias)
                case .failure(let error): Toast.displayError(error)
                }
            }
        }
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

        performSegue(withIdentifier: "showActivities", sender: alias)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        1.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        moreToLoad ? 44.0 : 1.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if moreToLoad {
            // swiftlint:disable:next line_length
            let loadingFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LoadingFooterView") as? LoadingFooterView
            loadingFooterView?.animate()
            return loadingFooterView
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if moreToLoad {
            fetchAliases()
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }

        let deleteAction =
            UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] _, indexPath in
                Vibration.warning.vibrate()
                self.presentAlertConfirmDelete(alias: alias, at: indexPath)
            }

        return [deleteAction]
    }
}

// MARK: - UITableViewDataSource
extension AliasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

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

        cell.didToggleStatus = { [unowned self] in
            self.toggle(alias: alias, at: indexPath)
        }

        cell.didTapCopyButton = {
            Vibration.soft.vibrate()
            UIPasteboard.general.string = alias.email
            Toast.displayShortly(message: "Copied \"\(alias.email)\"")
        }

        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showContacts", sender: alias)
        }

        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showActivities", sender: alias)
        }

        return cell
    }
}
