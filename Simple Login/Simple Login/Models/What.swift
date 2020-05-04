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
            Just hit "Reply" whenever you need to reply to a forwarded email: the reply will come from the alias and your personal mailbox stays hidden.
            
            You can also send emails to any email address from your alias.
            """
        case .c: return """
            Use alias as your business email.
            
            Save $6/month for each business email created with SimpleLogin.
            
            By the way your company emails are actually aliases.
            """
        }
    }
}
