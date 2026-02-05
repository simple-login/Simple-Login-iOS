//
//  LocalAliasExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 07/03/2022.
//

import CoreData
import SimpleLoginPackage

extension LocalAlias {
    static func createOrUpdate(from alias: Alias,
                               with managedContext: NSManagedObjectContext) throws {
        let fetchRequest = LocalAlias.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", alias.id)
        if let existingLocalAlias = try managedContext.fetch(fetchRequest).first {
            try existingLocalAlias.update(from: alias, with: managedContext)
        } else {
            try LocalAlias.create(from: alias, with: managedContext)
        }
    }

    private static func create(from alias: Alias,
                               with managedContext: NSManagedObjectContext) throws {
        let newLocalAlias = LocalAlias(context: managedContext)
        newLocalAlias.id = Int64(alias.id)
        newLocalAlias.blockCount = Int64(alias.blockCount)
        newLocalAlias.creationTimestamp = alias.creationTimestamp
        newLocalAlias.email = alias.email
        newLocalAlias.enabled = alias.enabled
        newLocalAlias.forwardCount = Int64(alias.forwardCount)
        newLocalAlias.name = alias.name
        newLocalAlias.note = alias.note
        newLocalAlias.pgpDisabled = alias.pgpDisabled
        newLocalAlias.pgpSupported = alias.pgpSupported
        newLocalAlias.pinned = alias.pinned
        newLocalAlias.replyCount = Int64(alias.replyCount)
        newLocalAlias.mailboxes = try alias.mailboxes.toLocalMailboxLites(with: managedContext)
    }

    private func update(from alias: Alias,
                        with managedContext: NSManagedObjectContext) throws {
        blockCount = Int64(alias.blockCount)
        creationTimestamp = alias.creationTimestamp
        email = alias.email
        enabled = alias.enabled
        forwardCount = Int64(alias.forwardCount)
        name = alias.name
        note = alias.note
        pgpDisabled = alias.pgpDisabled
        pgpSupported = alias.pgpSupported
        pinned = alias.pinned
        replyCount = Int64(alias.replyCount)
        mailboxes = try alias.mailboxes.toLocalMailboxLites(with: managedContext)
    }
}

private extension [MailboxLite] {
    func toLocalMailboxLites(with managedContext: NSManagedObjectContext) throws -> NSSet {
        let localMailboxLites = NSMutableSet()
        for mailbox in self {
            let fetchRequest = LocalMailboxLite.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %d", mailbox.id)
            if let existingLocalMailboxLite = try managedContext.fetch(fetchRequest).first {
                localMailboxLites.add(existingLocalMailboxLite)
            } else {
                let newLocalMailboxLite = LocalMailboxLite.create(from: mailbox,
                                                                  with: managedContext)
                localMailboxLites.add(newLocalMailboxLite)
            }
        }
        return localMailboxLites
    }
}
