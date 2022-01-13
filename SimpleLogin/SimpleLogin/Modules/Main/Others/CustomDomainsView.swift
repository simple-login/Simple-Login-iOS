//
//  CustomDomainsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import SimpleLoginPackage
import SwiftUI

struct CustomDomainsView: View {
    @StateObject private var viewModel = CustomDomainsViewModel()

    var body: some View {
        Text("Custom domains view")
    }
}

private struct DomainView: View {
    let domain: CustomDomain

    var body: some View {
        HStack {
            Image(systemName: domain.verified ? "checkmark.seal.fill" : "checkmark.seal")
                .resizable()
                .scaledToFit()
                .foregroundColor(domain.verified ? .green : .gray)
                .frame(width: 20, height: 20, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(domain.domainName)
                    .fontWeight(.semibold)
                Text("\(domain.relativeCreationDateString) • \(domain.aliasCount) alias(es)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !domain.verified {
                Text("Unverified")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.red, lineWidth: 1))
            }
        }
        .contentShape(Rectangle())
    }
}

struct CustomDomainsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DomainView(domain: .verified)
            DomainView(domain: .unverified)
        }
    }
}
