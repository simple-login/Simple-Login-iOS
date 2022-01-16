//
//  ColorExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/10/2021.
//

import SwiftUI

extension UIColor {
    static var slPurple: UIColor {
        UIColor(named: "AccentColor") ?? .purple
    }
}

extension Color {
    static var slPurple: Color {
        Color(.slPurple)
    }
}
