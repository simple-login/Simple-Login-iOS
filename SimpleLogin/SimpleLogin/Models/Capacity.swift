//
//  Capacity.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import Foundation

struct Capacity: Identifiable {
    let id = UUID()
    let description: String
    var detail: String?
}

extension Capacity {
    static var fifteenAliases: Capacity {
        .init(description: "10 aliases")
    }

    static var unlimitedBandWidth: Capacity {
        .init(description: "Unlimited bandwidth")
    }

    static var unlimitedReplySend: Capacity {
        .init(description: "Unlimited reply/send from alias")
    }

    static var oneMailbox: Capacity {
        .init(description: "1 mailbox")
    }

    static var browserExtensions: Capacity {
        .init(description: "Browser extensions", detail: "Chrome, Firefox and Safari")
    }

    static var totp: Capacity {
        .init(description: "Secure your account with TOTP and/or WebAuthn (FIDO)")
    }

    static var signWithSimpleLogin: Capacity {
        .init(description: "Sign in with SimpleLogin")
    }

    static var everythingInFreePlan: Capacity {
        .init(description: "Everything in the Free Plan")
    }

    static var unlimitedAliases: Capacity {
        .init(description: "Unlimited aliases")
    }

    static var unlimitedMailboxes: Capacity {
        .init(description: "Unlimited mailboxes")
    }

    static var unlimitedDomains: Capacity {
        .init(description: "Unlimited custom domains",
              detail: "Bring your own domain to create aliases like contact@your-domain.com")
    }

    static var catchAllDomain: Capacity {
        .init(description: "Catch-all (or wildcard) domain")
    }

    static var fiveSubdomains: Capacity {
        .init(description: "5 subdomains")
    }

    static var fiftyDirectories: Capacity {
        .init(description: "50 directories/usernames")
    }

    static var pgp: Capacity {
        .init(description: "PGP encryption")
    }
}
