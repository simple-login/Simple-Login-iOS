//
//  AliasesSearchView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import SwiftUI

struct AliasesSearchView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Text("Search")
                .navigationBarTitle("Search", displayMode: .inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Text("Close")
                                        }))
        }
    }
}

struct AliasesSearchView_Previews: PreviewProvider {
    static var previews: some View {
        AliasesSearchView()
    }
}
