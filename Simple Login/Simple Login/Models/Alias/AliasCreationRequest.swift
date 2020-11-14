//
//  AliasCreationRequest.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 05/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct AliasCreationRequest {
    let prefix: String
    let suffix: Suffix
    let mailboxIds: [Int]
    let name: String?
    let note: String?

    func toRequestBody() -> [String: Any] {
        var dict: [String: Any] = ["alias_prefix": prefix,
                                   "signed_suffix": suffix.signature,
                                   "mailbox_ids": mailboxIds]

        if let name = name { dict["name"] = name }
        if let note = note { dict["note"] = note }

        return dict
    }
}
