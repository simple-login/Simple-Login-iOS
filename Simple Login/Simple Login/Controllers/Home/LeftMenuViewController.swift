//
//  LeftMenuViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

protocol LeftMenuViewControllerDelegate: class {
    func didSelectAlias()
    func didSelectMailbox()
    func didSelectDirectory()
    func didSelectCustomDomain()
    func didSelectSettings()
    func didSelectAbout()
    func didSelectRateUs()
    func didSelectSignOut()
}

final class LeftMenuViewController: BaseViewController {
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var avatarImageView: AvatarImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    private var options: [[LeftMenuOption]] {
        let options: [[LeftMenuOption]] = [[.alias, .mailbox, .customDomains], [.separator], [.settings, .about], [.separator]]
        if UserDefaults.didMakeAReview() {
            return options + [[.signOut]]
        }
        return options + [[.rateUs, .signOut]]
    }

    var userInfo: UserInfo?
    weak var delegate: LeftMenuViewControllerDelegate?

    private var hasTopNotch: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0 > 20
        } else {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindUserInfo()
    }

    private func setUpUI() {
        view.backgroundColor = SLColor.menuBackgroundColor

        // topView
        topViewHeightConstraint.constant = hasTopNotch ? 150 : 120

        // shadowView
        let gradient = CAGradientLayer()
        gradient.colors = [SLColor.shadowColor.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = .init(x: 0.0, y: 0.0)
        gradient.endPoint = .init(x: 0.0, y: 1.0)
        gradient.frame = .init(origin: .zero, size: .init(width: shadowView.bounds.width, height: 5))
        shadowView.layer.insertSublayer(gradient, at: 0)
        shadowView.alpha = 0
        shadowView.backgroundColor = SLColor.shadowColor

        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear

        let footerView =
            UIView(frame: .init(origin: .zero, size: .init(width: tableView.bounds.width, height: 44)))
        let simpleLoginLabel = UILabel(frame: .zero)
        simpleLoginLabel.text = "SimpleLogin v\(kVersionString)"
        simpleLoginLabel.textColor = .lightGray
        simpleLoginLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        footerView.addSubview(simpleLoginLabel)
        simpleLoginLabel.fillSuperview(padding: UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20))

        tableView.tableFooterView = footerView

        LeftMenuOptionTableViewCell.register(with: tableView)
        SeparatorTableViewCell.register(with: tableView)
    }

    private func bindUserInfo() {
        guard let userInfo = userInfo else {
            usernameLabel.text = nil
            statusLabel.text = nil
            return
        }

        usernameLabel.text = userInfo.name
        emailLabel.text = userInfo.email

        if userInfo.inTrial {
            statusLabel.text = "Premium trial"
            statusLabel.textColor = .systemTeal
        } else if userInfo.isPremium {
            statusLabel.text = "Premium"
            statusLabel.textColor = SLColor.premiumColor
        } else {
            statusLabel.text = "Free plan"
            statusLabel.textColor = .white
        }

        avatarImageView.setImage(with: userInfo.profilePictureUrl)
    }
}

// MARK: - UITableViewDataSource
extension LeftMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { options.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let option = options[indexPath.section][indexPath.row]

        if option != .separator {
            return UITableView.automaticDimension
        }

        return 1 // separator cell
    }
}

// MARK: - UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.section][indexPath.row]

        switch option {
        case .alias: delegate?.didSelectAlias()
        case .mailbox: delegate?.didSelectMailbox()
        case .aliasDirectory: delegate?.didSelectDirectory()
        case .customDomains: delegate?.didSelectCustomDomain()
        case .settings: delegate?.didSelectSettings()
        case .about: delegate?.didSelectAbout()
        case .rateUs: delegate?.didSelectRateUs()
        case .signOut: delegate?.didSelectSignOut()
        case .separator: return
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.section][indexPath.row]

        if option != .separator {
            let cell = LeftMenuOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.bind(with: option)
            return cell
        }

        return SeparatorTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
    }
}

// MARK: - UIScrollViewDelegate
extension LeftMenuViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Animate shadowView's alpha base on tableView's contentOffset.y
        guard scrollView.contentOffset.y > 0 else { return }
        shadowView.alpha = scrollView.contentOffset.y / 44
    }
}
