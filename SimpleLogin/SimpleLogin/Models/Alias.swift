//
//  Alias.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/10/2021.
//

import Foundation
import SimpleLoginPackage

extension Alias {
    var mailboxesString: String {
        mailboxes.map { $0.email }.joined(separator: ", ")
    }

    var relativeCreationDateString: String {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.string(for: date) ?? ""
    }
}
