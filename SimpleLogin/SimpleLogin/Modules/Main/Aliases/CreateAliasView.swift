//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Text("Create")
                .navigationTitle("Create alias")
                .navigationBarItems(leading:
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Text("Close")
                                        }))
        }
    }
}

struct CreateAliasView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAliasView()
    }
}
