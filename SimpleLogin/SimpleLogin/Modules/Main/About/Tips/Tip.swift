//
//  Tip.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import Foundation

// swiftlint:disable:next type_name
enum Tip {
    case touchId, faceId, contextMenu, fullScreen, shareExtension, keyboardExtension

    var title: String {
        switch self {
        case .touchId:
            "Touch ID"
        case .faceId:
            "Face ID"
        case .contextMenu:
            "Context menu"
        case .fullScreen:
            "Full screen mode"
        case .shareExtension:
            "Share extension"
        case .keyboardExtension:
            "Keyboard extension"
        }
    }

    var description: String {
        switch self {
        case .touchId:
            "Restrict unwelcome access to your SimpleLogin application on this device with Touch ID."
        case .faceId:
            "Restrict unwelcome access to your SimpleLogin application on this device with Face ID."
        case .contextMenu:
            // swiftlint:disable:next line_length
            "Quickly take action on an alias by long pressing to reveal extra options.\nTry it with the test alias below 👇"
        case .fullScreen:
            // swiftlint:disable:next line_length
            "Show your aliases to other people easily without dictating. In alias detail page, either tap on alias or choose \"Enter Full Screen\" option."
        case .shareExtension:
            // swiftlint:disable:next line_length
            "Create aliases on the fly without leaving the current context. Whenever you need to create an alias for a website, simply \"share\" the URL and choose SimpleLogin."
        case .keyboardExtension:
            // swiftlint:disable:next line_length
            "Type your aliases without opening SimpleLogin application. Go to Settings ➝ General ➝ Keyboard ➝ Keyboards to enable SimpleLogin keyboard as well as \"Allow Full Access\""
        }
    }

    var action: String? {
        switch self {
        case .contextMenu, .faceId, .touchId:
            nil
        case .fullScreen, .shareExtension:
            "Try it"
        case .keyboardExtension:
            "Open settings"
        }
    }

    var systemIconName: String {
        switch self {
        case .touchId:
            "touchid"
        case .faceId:
            "faceid"
        case .contextMenu:
            "contextualmenu.and.cursorarrow"
        case .fullScreen:
            "iphone"
        case .shareExtension:
            "square.and.arrow.up"
        case .keyboardExtension:
            "keyboard"
        }
    }
}
