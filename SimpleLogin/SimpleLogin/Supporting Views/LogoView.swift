//
//  LogoView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        Image("LogoWithName")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.minLength / (UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3))
    }
}
