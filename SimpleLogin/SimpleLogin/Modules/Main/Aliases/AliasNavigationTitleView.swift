//
//  AliasNavigationTitleView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 23/04/2022.
//

import SimpleLoginPackage
import SwiftUI

struct AliasNavigationTitleView: View {
    let alias: Alias

    var body: some View {
        HStack {
            if alias.pinned {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.slPurple)
            }
            Text(alias.email)
                .fontWeight(.medium)
        }
        .opacity(alias.enabled ? 1 : 0.5)
        .frame(maxWidth: UIScreen.main.minLength * 3 / 4)
    }
}
