//
//  Step.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum Step: CaseIterable {
    case a, b, c
    
    var title: String {
        switch self {
        case .a: return "A. Hide your personal email address"
        case .b: return "B. Control who can send you emails"
        case .c: return "C. Reply with an alias"
        }
    }
    
    var imageName: String {
        switch self {
        case .a: return "StepA"
        case .b: return "StepB"
        case .c: return "StepC"
        }
    }
    
    var description: String {
        switch self {
        case .a: return """
            Create quickly a random, secure email alias on any website.
            
            All emails going to an alias will be forwarded to your personal inbox.
            """
        case .b: return """
            Simply block an alias if it's too spammy.
            """
        case .c: return """
            Not only an alias can receive emails, it can send emails too.
            
            Simply hit "Reply" in your favorite email client and the reply will come from the alias.
            
            Your personal email address is never revealed.
            """
        }
    }
}
