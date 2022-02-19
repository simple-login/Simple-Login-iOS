//
//  Tip.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import Foundation

// swiftlint:disable:next type_name
enum Tip {
    case contextMenu, fullScreen, shareExtension, keyboardExtension

    var title: String {
        switch self {
        case .contextMenu:
            return "Context menu"
        case .fullScreen:
            return "Full screen mode"
        case .shareExtension:
            return "Share extension"
        case .keyboardExtension:
            return "Keyboard extension"
        }
    }

    var description: String {
        switch self {
        case .contextMenu:
            return "Quickly take action on an alias by long pressing to reveal extra options.\nTry it with the alias below 👇 "
        case .fullScreen:
            return "Show your aliases to other people easily without dictating. In alias detail page, either tap on alias or choose \"Enter Full Screen\" option."
        case .shareExtension:
            return "Create aliases on the fly without leaving the current context. Whenever you need to create an alias for a website, simply \"share\" the URL and choose SimpleLogin."
        case .keyboardExtension:
            return "Type your aliases without opening SimpleLogin application. Go to Settings ➝ General ➝ Keyboard ➝ Keyboards to enable SimpleLogin keyboard as well as \"Allow Full Access\""
        }
    }

    var action: String? {
        switch self {
        case .contextMenu:
            return nil
        case .fullScreen, .shareExtension:
            return "Try it"
        case .keyboardExtension:
            return "Open settings"
        }
    }

    var systemIconName: String {
        switch self {
        case .contextMenu:
            return "contextualmenu.and.cursorarrow"
        case .fullScreen:
            return "iphone"
        case .shareExtension:
            return "square.and.arrow.up"
        case .keyboardExtension:
            return "keyboard"
        }
    }
}
