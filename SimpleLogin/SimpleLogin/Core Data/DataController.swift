//
//  DataController.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 07/03/2022.
//

import CoreData
import SimpleLoginPackage

struct DataController {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func update(_ aliases: [Alias]) throws {
        for alias in aliases {
            try LocalAlias.createOrUpdate(from: alias, with: context)
        }
        try context.save()
    }

    func update(_ alias: Alias) throws {
        try update([alias])
    }

    func delete(_ alias: Alias) throws {
        let fetchRequest = LocalAlias.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", alias.id)
        if let localAlias = try context.fetch(fetchRequest).first {
            context.delete(localAlias)
        }
        try context.save()
    }

    func reset() throws {
        let localAliases = try context.fetch(LocalAlias.fetchRequest())
        for localAlias in localAliases {
            context.delete(localAlias)
        }

        let localMailboxLites = try context.fetch(LocalMailboxLite.fetchRequest())
        for localMailboxLite in localMailboxLites {
            context.delete(localMailboxLite)
        }

        try context.save()
    }

    func fetchAliases(page: Int) throws -> [Alias] {
        let fetchRequest = LocalAlias.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "creationTimestamp", ascending: false)]
        fetchRequest.fetchLimit = kDefaultPageSize
        fetchRequest.fetchOffset = kDefaultPageSize * page
        return try context.fetch(fetchRequest).compactMap { Alias(from: $0) }
    }

    func fetchAliases(page: Int, searchTerm: String) throws -> [Alias] {
        let fetchRequest = LocalAlias.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "creationTimestamp", ascending: false)]
        fetchRequest.predicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                .init(format: "email CONTAINS[c] %@", searchTerm),
                .init(format: "note CONTAINS[c] %@", searchTerm),
                .init(format: "name CONTAINS[c] %@", searchTerm)
            ])
        fetchRequest.fetchLimit = kDefaultPageSize
        fetchRequest.fetchOffset = kDefaultPageSize * page
        return try context.fetch(fetchRequest).compactMap { Alias(from: $0) }
    }
}
