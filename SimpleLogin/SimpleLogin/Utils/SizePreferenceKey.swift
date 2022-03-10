//
//  SizePreferenceKey.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 10/03/2022.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue = CGSize.zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize

    let content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { preferences in
                self.size = preferences
            }
    }
}

extension View {
    func bindSize(_ size: Binding<CGSize>) -> some View {
        ChildSizeReader(size: size) {
            self
        }
    }
}
