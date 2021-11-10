//
//  AccountView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()

    var body: some View {
        Button(action: {
            try? KeychainService.shared.setApiKey(nil)
        }, label: {
            Text("Log out")
        })
    }
}
