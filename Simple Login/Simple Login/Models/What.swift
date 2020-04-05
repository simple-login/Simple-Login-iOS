//
//  What.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum What: CaseIterable {
    case a, b, c
    
    var title: String {
        switch self {
        case .a: return "A. Replace email by alias everywhere"
        case .b: return "B. Send emails from alias"
        case .c: return "C. Run your business with alias"
        }
    }
    
    var imageName: String {
        switch self {
        case .a: return "WhatA"
        case .b: return "WhatB"
        case .c: return "WhatC"
        }
    }
    
    var description: String {
        switch self {
        case .a: return """
            Subscribe to mailing lists, create new online accounts with email alias.

            All emails sent to an alias will be forwarded to your personal inbox.

            Later on, simply block an alias if it's too spammy.
            """
        case .b: return """
            Not only an alias can receive emails, it can send emails too.

            Just hit "Reply" whenever you need to reply to a forwarded email.

            The reply will come from the alias and your personal email address is never revealed.
            """
        case .c: return """
            Use alias as your business email.

            Save $6/month (GSuite starts at $6/month per user) for each business email created with SimpleLogin.

            By the way our company emails are actually aliases 🤫.
            """
        }
    }
}
