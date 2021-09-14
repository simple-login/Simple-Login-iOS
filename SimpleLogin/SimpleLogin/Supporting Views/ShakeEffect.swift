//
//  ShakeEffect.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/08/2021.
//

import SwiftUI

// https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translationX = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return .init(CGAffineTransform(translationX: translationX, y: 0))
    }
}
