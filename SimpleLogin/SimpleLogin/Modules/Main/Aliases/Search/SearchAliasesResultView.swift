//
//  SearchAliasesResultView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 05/02/2022.
//

import SwiftUI

struct SearchAliasesResultView: View {
    @ObservedObject var viewModel: SearchAliasesViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0...100, id: \.self) { i in
                    Text("\(i)")
                }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.endEditing()
            })
    }
}
