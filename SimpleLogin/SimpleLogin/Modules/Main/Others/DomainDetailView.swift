//
//  DomainDetailView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/01/2022.
//

import SimpleLoginPackage
import SwiftUI

struct DomainDetailView: View {
    let domain: CustomDomain

    var body: some View {
        Text(domain.domainName)
    }
}

struct DomainDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DomainDetailView(domain: .verified)
    }
}
