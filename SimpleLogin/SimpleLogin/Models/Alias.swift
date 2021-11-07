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

    var creationDate: Date {
        Date(timeIntervalSince1970: creationTimestamp)
    }

    var creationDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: creationDate)
    }

    var relativeCreationDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.string(for: creationDate) ?? ""
    }

    var noActivities: Bool {
        forwardCount + replyCount + blockCount == 0
    }
}
