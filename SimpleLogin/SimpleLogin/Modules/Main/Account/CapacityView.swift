//
//  CapacityView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

struct CapacityView: View {
    let capacity: Capacity
    let checkmarkColor: Color?

    var body: some View {
        Label {
            Text(capacity.description)
        } icon: {
            Image(systemName: "checkmark")
                .foregroundColor(checkmarkColor ?? .primary)
        }
        .fixedSize(horizontal: false, vertical: true)

        if let detail = capacity.detail {
            Label {
                Text(detail)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "circle")
                    .opacity(0)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
