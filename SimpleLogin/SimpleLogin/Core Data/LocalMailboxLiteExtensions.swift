//
//  LocalMailboxLiteExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 08/03/2022.
//

import CoreData
import SimpleLoginPackage

extension LocalMailboxLite {
    static func create(from mailboxLite: MailboxLite,
                       with managedContext: NSManagedObjectContext) -> LocalMailboxLite {
        let newLocalMailboxLite = LocalMailboxLite(context: managedContext)
        newLocalMailboxLite.id = Int64(mailboxLite.id)
        newLocalMailboxLite.email = mailboxLite.email
        return newLocalMailboxLite
    }
}
