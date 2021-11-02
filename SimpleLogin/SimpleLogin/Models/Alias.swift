//
//  Alias.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/10/2021.
//

import SimpleLoginPackage

extension Alias {
    var mailboxesString: String {
        mailboxes.map { $0.email }.joined(separator: ", ")
    }
}
