//
//  OthersView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AdvancedView: View {
    @EnvironmentObject private var session: SessionV2
    @State private var showingMailboxesView = false
    @State private var showingCustomDomainsView = false
    @State private var selectedUrlString: String?

    var body: some View {
        NavigationView {
            Form {
                Section(footer: mailboxesSectionFooter) {
                    NavigationLink(
                        isActive: $showingMailboxesView,
                        destination: {
                            MailboxesView(session: session)
                        },
                        label: {
                            Label("Mailboxes", systemImage: "tray.2.fill")
                        })
                }

                Section(footer: customDomainsSectionFooter) {
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
            .navigationTitle("Advanced")

            DetailPlaceholderView(systemIconName: "circle.grid.cross",
                                  message: "Select a menu to see its details here")
        }
        .slNavigationView()
        .betterSafariView(urlString: $selectedUrlString)
    }

    private var mailboxesSectionFooter: some View {
        Button("What are mailboxes?") {
            selectedUrlString = "https://simplelogin.io/docs/mailbox/add-mailbox/"
        }
        .foregroundColor(.slPurple)
    }

    private var customDomainsSectionFooter: some View {
        Button("What are custom domains?") {
            selectedUrlString = "https://simplelogin.io/docs/custom-domain/add-domain/"
        }
        .foregroundColor(.slPurple)
    }
}

struct OthersView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedView()
    }
}
