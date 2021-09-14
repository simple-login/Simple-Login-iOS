//
//  AliasesToolbar.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 04/09/2021.
//

import SwiftUI

enum AliasStatus: CustomStringConvertible, CaseIterable {
    case all, active, inactive

    var description: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .inactive: return "Inactive"
        }
    }
}

struct AliasesViewToolbar: View {
    @Binding var selectedStatus: AliasStatus
    let onSearch: () -> Void
    let onRandomAlias: () -> Void
    let onCreateAlias: () -> Void

    var body: some View {
        let topInset = UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0
        VStack(spacing: 0) {
            Spacer()
                .frame(height: topInset)

            HStack(spacing: 0) {
                Picker("", selection: $selectedStatus) {
                    ForEach(AliasStatus.allCases, id: \.self) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Divider()
                    .fixedSize()
                    .padding(.horizontal, 16)

                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                }

                Spacer()
                    .frame(width: 24)

                Button(action: onRandomAlias) {
                    Image(systemName: "shuffle")
                }

                Spacer()
                    .frame(width: 24)

                Button(action: onCreateAlias) {
                    Image(systemName: "plus")
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)

            Color(.separator)
                .frame(height: 0.5)
                .opacity(0.5)
        }
        .background(Color(.systemGray6).blur(radius: 3.0))
    }
}

struct AliasesToolbar_Previews: PreviewProvider {
    static var previews: some View {
        AliasesViewToolbar(selectedStatus: .constant(.all),
                       onSearch: {},
                       onRandomAlias: {},
                       onCreateAlias: {})
    }
}
