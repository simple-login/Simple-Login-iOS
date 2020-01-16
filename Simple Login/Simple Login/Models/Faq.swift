//
//  Faq.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum Faq: CaseIterable {
    case first, second, third, fourth
    
    var title: String {
        switch self {
        case .first: return "What is an email alias?"
        case .second: return "Is email alias permanent?"
        case .third: return "How SimpleLogin is different than temporary email services?"
        case .fourth: return "Do you read forwarded emails?"
        }
    }
    
    var description: String {
        switch self {
        case .first: return """
            Email alias is similar to forward email address: all emails sent to an alias will be forwarded to your inbox.
            
            Thanks to SimpleLogin technology, an alias can also send emails.
            
            For your contact, the alias is therefore your email address.
            """
        case .second: return """
            Yes! An email alias is actually a normal email address that exists forever unless you remove it on your SimpleLogin dashboard.
            """
        case .third: return """
            SimpleLogin alias are permanent as opposed to the temporary emails created on services like temp-mail.org, 10minutemail.net, etc.
            
            SimpleLogin also doesn't store the emails.
            
            We are simply different products for different usecases.
            """
        case .fourth: return """
            SimpleLogin doesn't store the emails (we don't want to become another Gmail 💰).

            Technically the emails DO arrive at SimpleLogin server and we modify email headers to implement the "magic" but the email content is never read.
            """
        }
    }
}
