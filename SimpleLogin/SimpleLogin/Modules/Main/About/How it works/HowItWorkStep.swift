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
            "Use email alias everywhere"
        case .two:
            "Receive emails safely in your inbox"
        case .three:
            "Send emails anonymously"
        }
    }

    var description: String {
        switch self {
        case .one:
            "Next time a website asks for your email address, give an alias instead of your real email."
        case .two:
            "Emails sent to an alias are forwarded to your inbox without the sender knowing anything."
        case .three:
            // swiftlint:disable:next line_length
            "Just hit \"Reply\" if you want to reply to a forwarded email: the reply is sent from your alias and your real email stays hidden.\nYou can also easily send emails from your alias."
        }
    }

    var imageName: String {
        switch self {
        case .one:
            "Step1"
        case .two:
            "Step2"
        case .three:
            "Step3"
        }
    }
}
