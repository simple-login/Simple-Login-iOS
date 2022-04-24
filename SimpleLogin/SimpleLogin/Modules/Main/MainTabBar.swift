//
//  MainTabBar.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 03/04/2022.
//

import SwiftUI

// swiftlint:disable let_var_whitespace
struct MainTabBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedItem: TabBarItem
    let onSelectCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Spacer()
                }
                tab(for: .aliases)
                tab(for: .advanced)
                createButton
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom != .phone ? 50 : 0)
                tab(for: .settings)
                tab(for: .myAccount)
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Spacer()
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func tab(for item: TabBarItem) -> some View {
        Tab {
            Image(systemName: selectedItem == item ? item.selectedImage : item.image)
            Text(item.title)
                .font(.caption)
        }
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom != .phone ? 130 : .infinity)
        .foregroundColor(selectedItem == item ? .slPurple : (colorScheme == .dark ? .white : .gray))
        .onTapGesture {
            selectedItem = item
        }
    }

    @ViewBuilder
    private var createButton: some View {
        let foregroundColor: Color = colorScheme == .dark ? .white : .gray
        Image(systemName: "plus")
            .font(.largeTitle.weight(.thin))
            .foregroundColor(foregroundColor)
            .padding(4)
            .clipShape(Circle())
            .overlay(Circle().stroke(foregroundColor, lineWidth: 1))
            .onTapGesture(perform: onSelectCreate)
    }
}

// swiftlint:disable:next type_name
struct Tab<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            VStack {
                content()
            }
        } else {
            HStack {
                content()
            }
        }
    }
}

enum TabBarItem {
    case aliases, advanced, myAccount, settings

    var title: String {
        switch self {
        case .aliases:
            return "Aliases"
        case .advanced:
            return "Advanced"
        case .myAccount:
            return "My account"
        case .settings:
            return "Settings"
        }
    }

    var image: String {
        switch self {
        case .aliases:
            return "at"
        case .advanced:
            return "circle.grid.cross"
        case .myAccount:
            return "person"
        case .settings:
            if #available(iOS 15, *) {
                return "gear.circle"
            } else {
                return "gearshape"
            }
        }
    }

    var selectedImage: String {
        switch self {
        case .aliases:
            return "at"
        case .advanced:
            return "circle.grid.cross.fill"
        case .myAccount:
            return "person.fill"
        case .settings:
            if #available(iOS 15, *) {
                return "gear.circle.fill"
            } else {
                return "gearshape.fill"
            }
        }
    }
}

struct DummyMainView: View {
    @State private var selectedItem = TabBarItem.aliases

    var body: some View {
        VStack {
            ZStack {
                Text("Hello world")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            MainTabBar(selectedItem: $selectedItem) {}
        }
    }
}

struct DummyMainView_Previews: PreviewProvider {
    static var previews: some View {
        DummyMainView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))

        DummyMainView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (5th generation) (15.2)"))
            .preferredColorScheme(.dark)
    }
}
