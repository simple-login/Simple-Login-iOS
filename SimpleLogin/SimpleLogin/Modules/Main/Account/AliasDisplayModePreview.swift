//
//  AliasDisplayModePreview.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 23/01/2022.
//

import SwiftUI

enum AliasDisplayMode: Int, CaseIterable {
    // swiftlint:disable:next explicit_enum_raw_value
    case `default` = 0, comfortable, compact

    var description: String {
        switch self {
        case .default: return "Default"
        case .comfortable: return "Comfortable"
        case .compact: return "Compact"
        }
    }
}

struct AliasDisplayModePreview: View {
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default

    var body: some View {
        HStack(spacing: 0) {
            Color(.slPurple)
                .frame(width: 4)

            VStack(spacing: 8) {
                // Email
                GrayRectangle()
                    .frame(maxWidth: .infinity)

                if displayMode != .compact {
                    // Creation date
                    GrayRectangle()
                        .frame(maxWidth: .infinity)

                    // Mailboxes
                    GrayRectangle()
                }

                // Activities
                if displayMode == .default {
                    GeometryReader { proxy in
                        HStack {
                            GrayRectangle()
                                .frame(width: proxy.size.width / 2)
                            Spacer()
                        }
                    }
                }

                // Actions
                HStack(spacing: 20) {
                    GrayRectangle()
                    GrayRectangle()
                    GrayRectangle()
                }
            }
            .padding(8)
        }
        .background(Color.slPurple.opacity(0.05))
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct GrayRectangle: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Color(.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
