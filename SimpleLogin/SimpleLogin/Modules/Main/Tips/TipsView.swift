//
//  TipsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import SwiftUI

struct TipsView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                VStack {
                    Text("Welcome to")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("SimpleLogin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.slPurple)
                    Text("Here are some useful tips to help you make the most out of this application.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                TipView(tip: .fullScreen)
                TipView(tip: .shareExtension)
                TipView(tip: .keyboardExtension)
            }
            .padding(.top, 20)
            .padding()
        }
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

private struct TipView: View {
    @State private var showingSheet = false
    let tip: Tip

    var body: some View {
        VStack {
            HStack {
                Text(tip.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text(tip.description)
                Image(systemName: tip.systemIconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.slPurple)
                    .frame(width: 40)
            }
            Button(action: {
                handleAction()
            }, label: {
                Text(tip.action)
                    .font(.headline)
            })
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.systemGray5), radius: 10, x: 0, y: 0)
        .sheet(isPresented: $showingSheet) {
            switch tip {
            case .fullScreen:
                AliasEmailView(email: "a-long-and-complicated-alias@my-domain.com")
            case .shareExtension:
                ShareSheetView(activityItems: [URL(string: "https://www.wikipedia.org/")])
            case .keyboardExtension:
                EmptyView()
            }
        }
    }

    private func handleAction() {
        switch tip {
        case .fullScreen, .shareExtension:
            showingSheet = true
        case .keyboardExtension:
            UIApplication.shared.openSettings()
        }
    }
}
