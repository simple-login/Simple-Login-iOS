//
//  OthersView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct OthersView: View {
    @EnvironmentObject private var session: Session
    @State private var showingMailboxesView = false
    @State private var showingCustomDomainsView = false

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("The mailboxes that receive and send emails")) {
                    NavigationLink(
                        isActive: $showingMailboxesView,
                        destination: {
                            MailboxesView(session: session)
                        },
                        label: {
                            Label("Mailboxes", systemImage: "tray.2.fill")
                        })
                }

                Section(footer: Text("The domains that you own")) {
                    NavigationLink(
                        isActive: $showingCustomDomainsView,
                        destination: {
                            CustomDomainsView(session: session)
                        },
                        label: {
                            Label("Custom domains", systemImage: "globe")
                        })
                }
            }
            .navigationTitle("Other functionalities")

            DetailPlaceholderView(systemIconName: "circle.grid.cross",
                                  message: "Select a menu to see its details here")
        }
        .slNavigationView()
    }
}

struct OthersView_Previews: PreviewProvider {
    static var previews: some View {
        OthersView()
    }
}
