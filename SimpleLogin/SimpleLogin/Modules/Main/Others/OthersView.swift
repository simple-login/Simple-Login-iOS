//
//  OthersView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct OthersView: View {
    @State private var showingMailboxesView = false
    @State private var showingCustomDomainsView = false

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("The mailboxes that receive and send emails")) {
                    NavigationLink(isActive: $showingMailboxesView,
                                   destination: { MailboxesView() },
                                   label: { Label("Mailboxes",
                                                  systemImage: "tray.2.fill") })
                }

                Section(footer: Text("The domains that you own")) {
                    NavigationLink(isActive: $showingCustomDomainsView,
                                   destination: { CustomDomainsView() },
                                   label: { Label("Custom domains",
                                                  systemImage: "globe") })
                }
            }
            .navigationTitle("Other functionalities")
        }
    }
}

struct OthersView_Previews: PreviewProvider {
    static var previews: some View {
        OthersView()
    }
}
