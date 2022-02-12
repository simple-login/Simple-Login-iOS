//
//  BetterSafariViewExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import BetterSafariView
import Foundation

extension SafariView {
    init(url: URL) {
        let safariView =
        SafariView(url: url,
                   configuration: .init(entersReaderIfAvailable: true, barCollapsingEnabled: true))
            .accentColor(.slPurple)
            .dismissButtonStyle(.done)
        self = safariView
    }
}
