//
//  LocalDatabase.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 07/03/2022.
//

import CoreData
import SimpleLoginPackage
import SwiftUI

final class LocalDatabase {
    private let container = NSPersistentContainer(name: "SimpleLogin")

    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        }
    }

    func update(_ aliases: [Alias]) throws {
        let managedContext = container.viewContext
        for alias in aliases {
            try LocalAlias.createOrUpdate(from: alias, with: managedContext)
        }
        try managedContext.save()
    }

    func update(_ alias: Alias) throws {
        try update([alias])
    }

    func delete(_ alias: Alias) throws {
        let managedContext = container.viewContext
        let fetchRequest = LocalAlias.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", alias.id)
        if let localAlias = try managedContext.fetch(fetchRequest).first {
            managedContext.delete(localAlias)
        }
        try managedContext.save()
    }
}
