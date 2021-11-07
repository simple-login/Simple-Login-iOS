//
//  AliasDetailViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import SimpleLoginPackage
import SwiftUI

final class AliasDetailViewModel: ObservableObject {
    @Published private(set) var alias: Alias

    init(alias: Alias) {
        self.alias = alias
    }
}
