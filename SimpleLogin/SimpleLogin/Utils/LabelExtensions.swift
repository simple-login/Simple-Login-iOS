//
//  LabelExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 17/02/2022.
//

import SwiftUI

extension Label where Title == Text, Icon == Image {
    static var activate: Label {
        Label("Activate", systemImage: "checkmark.circle")
    }

    static var copy: Label {
        Label("Copy", systemImage: "doc.on.doc")
    }

    static var deactivate: Label {
        Label("Deactivate", systemImage: "circle.dashed")
    }

    static var delete: Label {
        Label("Delete", systemImage: "trash")
    }

    static var enterFullScreen: Label {
        Label("Enter Full Screen", systemImage: "iphone")
    }

    static var pin: Label {
        Label("Pin", systemImage: "bookmark")
    }

    static var sendEmail: Label {
        Label("Send email", systemImage: "paperplane")
    }

    static var unpin: Label {
        Label("Unpin", systemImage: "bookmark.slash")
    }
}
