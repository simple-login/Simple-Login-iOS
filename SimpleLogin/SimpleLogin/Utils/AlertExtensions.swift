//
//  AlertExtensions.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 19/02/2022.
//

import SimpleLoginPackage
import SwiftUI

extension Alert {
    static func deleteConfirmation(alias: Alias, onDelete: @escaping () -> Void) -> Alert {
        Alert(title: Text("Delete \(alias.email)?"),
              message: Text("This can not be undone. Please confirm"),
              primaryButton: .destructive(Text("Yes, delete this alias"), action: onDelete),
              secondaryButton: .cancel())
    }
}
