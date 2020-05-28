//
//  LeftMenuOption.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum LeftMenuOption: CustomStringConvertible {
    case separator, alias, mailbox, aliasDirectory, customDomains, settings, about, rateUs, signOut
    
    var description: String {
        switch self {
        case .separator: return ""
        case .alias: return "Aliases"
        case .mailbox: return "Mailboxes"
        case .aliasDirectory: return "Alias Directories"
        case .customDomains: return "Custom Domains"
        case .settings: return "Settings"
        case .about: return "About"
        case .rateUs: return "Rate Us"
        case .signOut: return "Sign Out"
        }
    }
    
    var iconName: String {
        switch self {
        case .separator: return ""
        case .alias: return "HouseIcon"
        case .mailbox: return "MailboxIcon"
        case .aliasDirectory: return "FolderIcon"
        case .customDomains: return "DnsIcon"
        case .settings: return "SettingsIcon"
        case .about: return "InfoIcon"
        case .rateUs: return "StarIcon"
        case .signOut: return "SignOutIcon"
        }
    }
}
