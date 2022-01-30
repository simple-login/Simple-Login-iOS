//
//  NoSessionView.swift
//  ShareExtension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import SwiftUI

struct NoSessionView: View {
    var onLogIn: (() -> Void)?
    var body: some View {
        VStack(alignment: .center) {
            Text("Please log in in order to use Share Extension")
            Button(action: {

            }, label: {
                Text("Log in")
            })
        }
        .padding(.horizontal)
    }
}
