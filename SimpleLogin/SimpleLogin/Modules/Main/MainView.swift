//
//  MainView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import SimpleLoginPackage
import SwiftUI

enum MainViewTab {
    case aliases, others, account, about

    var title: String {
        switch self {
        case .aliases: return "Aliases"
        case .others: return "Others"
        case .account: return "My account"
        case .about: return "About"
        }
    }
}

struct MainView: View {
    @State private var selectedTab: MainViewTab = .aliases
    let apiKey: ApiKey
    let client: SLClient

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                AliasesView(apiKey: apiKey, client: client)
                    .tabItem {
                        Image(systemName: "at")
                        Text(MainViewTab.aliases.title)
                    }
                    .tag(MainViewTab.aliases)

                OthersView(apiKey: apiKey, client: client)
                    .tabItem {
                        Image(systemName: selectedTab == .others ? "tray.2.fill" : "tray.2")
                        Text(MainViewTab.others.title)
                    }
                    .tag(MainViewTab.others)

                AccountView(apiKey: apiKey, client: client)
                    .tabItem {
                        Image(systemName: selectedTab == .account ? "person.fill" : "person")
                        Text(MainViewTab.account.title)
                    }
                    .tag(MainViewTab.account)

                AboutView()
                    .tabItem {
                        Image(systemName: selectedTab == .about ? "info.circle.fill" : "info.circle")
                        Text(MainViewTab.about.title)
                    }
                    .tag(MainViewTab.about)
            }
        }
    }
}
