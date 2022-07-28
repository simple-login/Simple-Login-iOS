//
//  HowItWorkStep.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 26/02/2022.
//

import Foundation

enum HowItWorkStep {
    case one, two, three

    var title: String {
        switch self {
        case .one:
            return "Use email alias everywhere"
        case .two:
            return "Receive emails safely in your inbox"
        case .three:
            return "Send emails anonymously"
        }
    }

    var description: String {
        switch self {
        case .one:
            return "Next time a website asks for your email address, give an alias instead of your real email."
        case .two:
            return "Emails sent to an alias are forwarded to your inbox without the sender knowing anything."
        case .three:
            // swiftlint:disable:next line_length
            return "Just hit \"Reply\" if you want to reply to a forwarded email: the reply is sent from your alias and your real email stays hidden.\nYou can also easily send emails from your alias."
        }
    }

    var imageName: String {
        switch self {
        case .one:
            return "Step1"
        case .two:
            return "Step2"
        case .three:
            return "Step3"
        }
    }
}
