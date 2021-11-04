//
//  OthersView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct OthersView: View {
    @StateObject private var viewModel = OthersViewModel()

    var body: some View {
        Text("Others")
            .navigationTitle("Others")
    }
}
