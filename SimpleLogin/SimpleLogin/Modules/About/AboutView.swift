//
//  AboutView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Text("About SimpleLogin")
                .navigationTitle("About")
        }
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        }))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
