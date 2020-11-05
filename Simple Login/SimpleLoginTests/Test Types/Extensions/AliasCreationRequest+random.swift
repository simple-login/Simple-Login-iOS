//
//  AliasCreationRequest+random.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 05/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin

extension AliasCreationRequest {
    static func random() -> AliasCreationRequest {
        let randomPrefix = String.randomName()
        let randomSuffix = Suffix.random()
        let randomMailboxIds = [0...Int.random(in: 1...10)].map { _ in Int.randomPageId() }
        let randomName = String.randomNullableName()
        let randomNote = String.randomNullableName()

        return AliasCreationRequest(prefix: randomPrefix,
                                    suffix: randomSuffix,
                                    mailboxIds: randomMailboxIds,
                                    name: randomName,
                                    note: randomNote)
    }
}
