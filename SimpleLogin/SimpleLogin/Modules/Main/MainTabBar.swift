import SwiftUI

enum TabBarItem {
    case aliases, advanced, myAccount, settings
}

#if DEBUG
import SimpleLoginPackage

/// Offline visual checks using sample data only. Launch with --layout-preview.
struct LayoutValidationView: View {
    @State private var status = AliasStatus.all
    @State private var selectedTab = TabBarItem.aliases
    @State private var message = ""
    @State private var showingMessage = false

    private var stats: Stats? {
        let json = "{\"nb_alias\":9,\"nb_forward\":132,\"nb_reply\":2,\"nb_block\":0}"
        return try? JSONDecoder().decode(Stats.self, from: Data(json.utf8))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                List {
                    Section {
                        AliasStatusPicker(selection: $status)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    if let stats {
                        Section {
                            StatsView(stats: stats)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    Section {
                        ForEach([Alias.ccohen, .claypool, .sample], id: \.id) { alias in
                            AliasCompactView(alias: alias,
                                             onCopy: { report("Copy") },
                                             onSendMail: { report("Contacts") },
                                             onToggle: { report("Toggle") },
                                             onPin: {}, onUnpin: {}, onDelete: {})
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Aliases")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { report("Search") } label: {
                            Label("Search aliases", systemImage: "magnifyingglass")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { report("Create") } label: {
                            Label("Create alias", systemImage: "plus")
                        }
                    }
                }
            }
            .tabItem { Label("Aliases", systemImage: "at") }.tag(TabBarItem.aliases)
            NavigationView { Text("Offline layout preview").navigationTitle("Advanced") }
                .tabItem { Label("Advanced", systemImage: "square.grid.2x2") }.tag(TabBarItem.advanced)
            NavigationView { Text("Offline layout preview").navigationTitle("Account") }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }.tag(TabBarItem.myAccount)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }.tag(TabBarItem.settings)
        }
        .tint(.slPurple)
        .alert(message, isPresented: $showingMessage) { Button("OK", role: .cancel) {} }
    }

    private func report(_ action: String) {
        message = action
        showingMessage = true
    }
}
#endif
