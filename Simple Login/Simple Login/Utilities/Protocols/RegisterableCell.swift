//
//  RegisterableCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

protocol RegisterableCell {
    associatedtype ScrollViewType
    
    static var identifier: String { get }
    static var nib: UINib? { get }
    
    static func register(with scrollView: ScrollViewType)
    static func dequeueFrom(_ scrollView: ScrollViewType, forIndexPath indexPath: IndexPath) -> Self
}

// Extend protocol to create default implementations
extension RegisterableCell {
    static var identifier: String {
        return "\(Self.self)"
    }
    
    static var nib: UINib? {
        if let _ = Bundle.main.path(forResource: "\(Self.self)", ofType: "nib") {
            return UINib(nibName: "\(Self.self)", bundle: nil)
        }
        
        return nil
    }
}

// MARK: - RegisterableTableViewCell
extension UITableViewCell {
    typealias ScrollViewType = UITableView
}

extension RegisterableCell where Self : UITableViewCell {
    static func register(with tableView: UITableView) {
        if let cellNib = nib {
            tableView.register(cellNib, forCellReuseIdentifier: identifier)
        } else {
            tableView.register(Self.self as AnyClass, forCellReuseIdentifier: identifier)
        }
    }
    
    static func dequeueFrom(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> Self {
        let anyCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        guard let cell = anyCell as? Self else {
            fatalError("\(Self.self) is not registed for tableview")
        }
        return cell
    }
}

// MARK: - RegisterableCollectionViewCell
extension UICollectionViewCell {
    typealias ScrollViewType = UICollectionView
}

extension RegisterableCell where Self : UICollectionViewCell {
    static func register(with collectionView: UICollectionView) {
        if let cellNib = self.nib {
            collectionView.register(cellNib, forCellWithReuseIdentifier: identifier)
        } else {
            collectionView.register(Self.self as AnyClass, forCellWithReuseIdentifier: identifier)
        }
    }
    
    static func dequeueFrom(_ collectionView: UICollectionView, forIndexPath indexPath: IndexPath) -> Self {
        let anyCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        guard let cell = anyCell as? Self else {
            fatalError("\(Self.self) is not registed for collectionview")
        }
        return cell
    }
}
