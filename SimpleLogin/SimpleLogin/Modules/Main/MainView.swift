//
//  MainView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import SimpleLoginPackage
import SwiftUI

struct MainView: View {
    let apiKey: ApiKey

    var body: some View {
        Text(apiKey.value)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(apiKey: .init(value: ""))
    }
}
