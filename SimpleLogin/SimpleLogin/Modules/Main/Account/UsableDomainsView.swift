//
//  DefaultDomainsView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 25/04/2022.
//

import SimpleLoginPackage
import SwiftUI

struct UsableDomainsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedUsableDomain: UsableDomain?
    let usableDomains: [UsableDomain]

    var body: some View {
        Form {
            ForEach(usableDomains, id: \.domain) { usableDomain in
                HStack {
                    UsableDomainView(usableDomain: usableDomain)
                    Spacer()
                    if usableDomain.domain == selectedUsableDomain?.domain {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedUsableDomain = usableDomain
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UsableDomainView: View {
    let usableDomain: UsableDomain

    var body: some View {
        VStack(alignment: .leading) {
            Text(usableDomain.domain)
                .fontWeight(.medium)
            let domainType: Suffix.DomainType = usableDomain.isCustom ? .custom : .simpleLogin
            Text(domainType.localizedDescription)
                .font(.caption)
                .foregroundColor(domainType.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
