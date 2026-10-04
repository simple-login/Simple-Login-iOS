//
// StatsView.swift
// SimpleLogin - Created on 07/02/2024.
// Copyright (c) 2024 Proton Technologies AG
//
// This file is part of SimpleLogin.
//
// SimpleLogin is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SimpleLogin is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SimpleLogin. If not, see https://www.gnu.org/licenses/.
//

import SimpleLoginPackage
import SwiftUI

struct StatsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let stats: Stats

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) { cells }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    cells
                }
            }
        }
        .id(dynamicTypeSize)
    }

    @ViewBuilder private var cells: some View {
        cell(title: "Aliases", description: "All time", count: stats.aliasCount)
        cell(title: "Forwarded", description: "Last 14 days", count: stats.forwardCount)
        cell(title: "Replies sent", description: "Last 14 days", count: stats.replyCount)
        cell(title: "Blocked", description: "Last 14 days", count: stats.blockCount)
    }

    private func cell(title: String, description: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.medium))
            Text(count, format: .number)
                .font(.title2.bold())
                .monospacedDigit()
            Text(description).font(.caption).foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
