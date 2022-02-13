//
//  CollectionExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 13/02/2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
