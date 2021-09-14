//
//  OthersView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct OthersView: View {
    @StateObject private var viewModel: OthersViewModel

    init(apiKey: ApiKey, client: SLClient) {
        _viewModel = StateObject(wrappedValue: .init(apiKey: apiKey, client: client))
    }

    var body: some View {
        Text("Others")
            .navigationTitle("Others")
    }
}
