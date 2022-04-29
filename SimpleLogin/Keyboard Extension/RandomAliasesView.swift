//
//  RandomAliasesView.swift
//  Keyboard Extension
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SwiftUI

struct RandomAliasesView: View {
    @ObservedObject var viewModel: KeyboardContentViewModel

    var body: some View {
        VStack(spacing: 20) {
            Group {
                Button("Random by word") {
                    viewModel.random(mode: .word)
                }

                Button("Random by UUID") {
                    viewModel.random(mode: .uuid)
                }
            }
            .foregroundColor(.slPurple)
            .font(.body)
        }
    }
}
