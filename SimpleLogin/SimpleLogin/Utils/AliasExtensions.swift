//
//  AliasExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 09/03/2022.
//

import SimpleLoginPackage

extension Alias {
    init?(from localAlias: LocalAlias) {
        guard let email = localAlias.email else { return nil }
        var mailboxes = [MailboxLite]()
        if let localMailboxLites = localAlias.mailboxes?.allObjects as? [LocalMailboxLite] {
            mailboxes = localMailboxLites.compactMap { MailboxLite(from: $0) }
        }
        self.init(id: Int(localAlias.id),
                  email: email,
                  name: localAlias.name,
                  enabled: localAlias.enabled,
                  creationTimestamp: localAlias.creationTimestamp,
                  blockCount: Int(localAlias.blockCount),
                  forwardCount: Int(localAlias.forwardCount),
                  replyCount: Int(localAlias.replyCount),
                  note: localAlias.note,
                  pgpSupported: localAlias.pgpSupported,
                  pgpDisabled: localAlias.pgpDisabled,
                  mailboxes: mailboxes,
                  latestActivity: nil,
                  pinned: localAlias.pinned)
    }
}

private extension MailboxLite {
    init?(from localMailboxLite: LocalMailboxLite) {
        guard let email = localMailboxLite.email else { return nil }
        self.init(id: Int(localMailboxLite.id), email: email)
    }
}
